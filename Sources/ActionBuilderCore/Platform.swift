// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/02/20.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

public final class Platform: Identifiable, Sendable {
  public let id: ID
  public let name: String
  public let subPlatforms: [Platform]
  public let needsDestination: Bool

  public enum ID: String, Codable, CaseInsensitiveRawRepresentable, Sendable {
    case macOS
    case iOS
    case tvOS
    case watchOS
    case visionOS
    case catalyst
    case linux
    case xcode
  }

  public static let platforms = [
    Platform(.macOS, name: "macOS"),
    Platform(.iOS, name: "iOS", needsDestination: true),
    Platform(.tvOS, name: "tvOS", needsDestination: true),
    Platform(.watchOS, name: "watchOS", needsDestination: true),
    Platform(.visionOS, name: "visionOS", needsDestination: true),
    Platform(.linux, name: "Linux"),
  ]

  public init(
    _ id: ID, name: String, needsDestination: Bool = false, subPlatforms: [Platform] = []
  ) {
    self.id = id
    self.name = name
    self.needsDestination = needsDestination
    self.subPlatforms = subPlatforms
  }

  /// Xcodebuild command to download support for this platform.
  public var xcodePlatformDownloadCommand: String {
    let platform: String
    let name: String

    switch id {
      case .macOS, .catalyst, .linux, .xcode:
        return ""

      case .iOS:
        platform = "iOS Simulator"
        name = "iPhone"

      case .tvOS:
        platform = "tvOS Simulator"
        name = "Apple TV"

      case .watchOS:
        platform = "watchOS Simulator"
        name = "Apple Watch"
      case .visionOS:
        platform = "visionOS Simulator"
        name = "Apple Vision"
    }

    return
      """
                  xcodebuild -downloadPlatform \(id.rawValue) > logs/download-\(id.rawValue).log
                  xcodebuild -workspace \"$WORKSPACE\" -scheme \"$SCHEME\" -showdestinations > logs/destinations-\(id.rawValue).log
                  DESTINATION=$(cat logs/destinations-\(id.rawValue).log | grep "platform:\(platform)" | grep "name:\(name)" | head -n 1 | awk -F" }" '{print$1}' | awk -F"name:" '{print$2}')
      """

  }

  public func jobName(with compiler: Compiler) -> String {
    if !subPlatforms.isEmpty {
      switch compiler.mac {
        case .xcode(let version, _), .toolchain(let version, _, _):
          let xcodeName = compiler.id == .swiftNightly ? "Xcode \(version)" : "Xcode matching Swift \(compiler.short)"
          return "\(name) (\(compiler.name), \(xcodeName))"
      }
    }

    return "\(name) (\(compiler.name))"
  }

  public func yaml(repo: Repo, compilers: [Compiler], configurations: [Configuration]) -> String {
    let package = repo.name
    let shouldTest = repo.testMode != .build

    var yaml = ""
    var xcodeToolchain: String? = nil
    var xcodeVersion: String? = nil

    for compiler in compilers {
      var job =
        """

            \(id)-\(compiler.id):
                name: \(jobName(with: compiler))
        """

      containerYAML(&job, compiler, &xcodeToolchain, &xcodeVersion)
      commonYAML(&job)
      makeLogsYAML(&job)

      if let branch = xcodeToolchain, let version = xcodeVersion {
        selectToolchainYAML(&job, branch, version)
      } else if !subPlatforms.isEmpty {
        selectXcodeYAML(&job, compiler: compiler)
      } else {
        selectSwiftYAML(&job, compiler: compiler)
      }

      if subPlatforms.isEmpty {
        job.append(
          runSwiftYAML(
            configurations: configurations, test: shouldTest,
            customToolchain: xcodeToolchain != nil, compiler: compiler))
      } else {
        for platform in subPlatforms {
          job.append(
            platform.runXcodebuildYAML(
              configurations: configurations, package: package, test: shouldTest, compiler: compiler
            ))
        }
        uploadYAML(&job, compiler: compiler)
      }

      if repo.postSlackNotification {
        job.append(notifyYAML(compiler: compiler))
      }

      yaml.append("\(job)\n\n")
    }

    return yaml
  }

  fileprivate func selectSwiftYAML(
    _ yaml: inout String, compiler: Compiler
  ) {
    yaml.append(
      """

              - name: Select Swift
                uses: swift-actions/setup-swift@v2
                with:
                  swift-version: "\(compiler.swiftlyName)"
      """)
  }

  fileprivate func runSwiftYAML(
    configurations: [Configuration], test: Bool, customToolchain: Bool, compiler: Compiler
  ) -> String {
    var yaml = """

              - name: Swift Version
                run: swift --version
      """

    let beautify = id == .macOS ? " | xcbeautify --quiet --disable-logging --renderer github-actions" : compiler.quietFlag
    let pathFix = customToolchain ? "export PATH=\"swift-latest:$PATH\"; " : ""
    if test {
      for config in configurations {
        yaml.append(
          compiler.supportsSeparateTestMethods
            ? """

                    - name: Build (\(config))
                      run: \(pathFix)swift build --configuration \(config)\(compiler.quietFlag)
                    - name: Test (\(config) XCTest)
                      run: |
                        set -o pipefail
                        \(pathFix)swift test --disable-swift-testing --configuration \(config)\(beautify)
                    - name: Test (\(config) Swift Testing)
                      run: |
                        set -o pipefail
                        \(pathFix)swift test --disable-xctest --configuration \(config)\(beautify)
            """
            : """

                    - name: Build (\(config))
                      run: \(pathFix)swift build --configuration \(config)\(compiler.quietFlag)
                    - name: Test (\(config))
                      run: |
                        set -o pipefail
                        \(pathFix)swift test --configuration \(config)\(beautify)
            """
        )
      }
    } else {
      for config in configurations {
        yaml.append(
          """

                  - name: Build (\(config))
                    run: \(pathFix)swift build -c \(config)\(compiler.quietFlag)
          """
        )
      }
    }

    return yaml
  }

  fileprivate func runXcodebuildYAML(
    configurations: [Configuration], package: String, test: Bool, compiler: Compiler
  ) -> String {
    var yaml = ""
    let destination = needsDestination ? "-destination \"name=$DESTINATION\"" : ""

    let setup = """
                  set -o pipefail
                  source "setup.sh"
      \(xcodePlatformDownloadCommand)
      """


    yaml.append(
      """

              - name: Detect Workspace & Scheme (\(name))
                run: |
                  WORKSPACE="\(package).xcworkspace"
                  if [[ ! -e "$WORKSPACE" ]]
                  then
                    WORKSPACE="."
                    GOTPACKAGE=$(xcodebuild -workspace . -list | (grep \(package)-Package || true))
                    if [[ $GOTPACKAGE != "" ]]
                    then
                      SCHEME="\(package)-Package"
                    else
                      SCHEME="\(package)"
                    fi
                  else
                    SCHEME="\(package)-\(name)"
                  fi
                  echo "export PATH='swift-latest:$PATH'; WORKSPACE='$WORKSPACE'; SCHEME='$SCHEME'" > setup.sh
      """
    )

    if test && compiler.supportsTesting(on: id) {
      for config in configurations {
        let extraArgs = config == .release ? "ENABLE_TESTABILITY=YES" : ""
        yaml.append(
          """

                  - name: Test (\(name) \(config.name))
                    run: |
          \(setup)
                      echo "Testing workspace $WORKSPACE scheme $SCHEME on $DESTINATION."
                      xcodebuild test -workspace "$WORKSPACE" -scheme "$SCHEME" \(destination) -configuration \(config.xcodeID) CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \(extraArgs) | tee logs/xcodebuild-\(id)-test-\(config).log | xcbeautify --quiet --disable-logging --renderer github-actions
          """
        )
      }
    } else {
      for config in configurations {
        let extraArgs = config == .release ? "ENABLE_TESTABILITY=YES" : ""
        yaml.append(
          """

                  - name: Build (\(name) \(config))
                    run: |
          \(setup)
                      echo "Building workspace $WORKSPACE scheme $SCHEME."
                      xcodebuild clean build -workspace "$WORKSPACE" -scheme "$SCHEME" \(destination) -configuration \(config.xcodeID) CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO \(extraArgs) | tee logs/xcodebuild-\(id)-build-\(config).log | xcbeautify --quiet --disable-logging --renderer github-actions
          """
        )
      }
    }

    return yaml
  }

  fileprivate func uploadYAML(_ yaml: inout String, compiler: Compiler) {
    yaml.append(
      """

              - name: Upload Logs
                uses: actions/upload-artifact@v4
                if: always()
                with:
                  name: \(id)-\(compiler.id)-logs
                  path: logs
      """
    )
  }

  fileprivate func notifyYAML(compiler: Compiler) -> String {
    var yaml = ""
    yaml.append(
      """

              - name: Slack Notification
                uses: elegantchaos/slatify@master
                if: always()
                with:
                  type: ${{ job.status }}
                  job_name: '\(name) (\(compiler.name))'
                  mention_if: 'failure'
                  url: ${{ secrets.SLACK_WEBHOOK }}
      """
    )
    return yaml
  }

  fileprivate func selectToolchainYAML(_ yaml: inout String, _ branch: String, _ version: String) {
    let download =
      """
                  branch="\(branch)"
                  wget --quiet https://download.swift.org/$branch/xcode/latest-build.yml
                  grep "download:" < latest-build.yml > filtered.yml
                  sed -e 's/-osx.pkg//g' filtered.yml > stripped.yml
                  sed -e 's/:[^:\\/\\/]/YML="/g;s/$/"/g;s/ *=/=/g' stripped.yml > snapshot.sh
                  source snapshot.sh
                  echo "Installing Toolchain: $downloadYML"
                  wget --quiet https://swift.org/builds/$branch/xcode/$downloadYML/$downloadYML-osx.pkg
                  sudo installer -pkg $downloadYML-osx.pkg -target /
                  ln -s "/Library/Developer/Toolchains/$downloadYML.xctoolchain/usr/bin" swift-latest
      """

    yaml.append(
      """

              - name: Select Xcode Version
                uses: maxim-lobanov/setup-xcode@v1
                with:
                  xcode-version: "\(version)"
              - name: Install Toolchain
                run: |
      \(download)
                  ls -d /Applications/Xcode* > logs/xcode-versions.log
                  swift --version
              - name: Xcode Version
                run: |
                  xcodebuild -version
                  xcrun swift --version
      """
    )
  }

  fileprivate func selectXcodeYAML(_ yaml: inout String, compiler: Compiler) {
    yaml.append(
      """

              - name: Resolve Xcode Version
                id: resolve-xcode
                run: |
                  REQUESTED_SWIFT="\(compiler.short)"
                  ls -d /Applications/Xcode* > logs/xcode-versions.log
                  FOUND_XCODE=""
                  while read -r APP
                  do
                    DEV_DIR="$APP/Contents/Developer"
                    SWIFT_VERSION=$(DEVELOPER_DIR="$DEV_DIR" xcrun swift --version 2>/dev/null | head -n 1 | sed -E 's/.*version ([0-9]+\\.[0-9]+).*/\\1/')
                    XCODE_VERSION=$(DEVELOPER_DIR="$DEV_DIR" xcodebuild -version 2>/dev/null | awk '/^Xcode / {print $2; exit}')
                    if [[ "$SWIFT_VERSION" == "$REQUESTED_SWIFT" ]]
                    then
                      FOUND_XCODE="$XCODE_VERSION"
                      break
                    fi
                  done < <(ls -d /Applications/Xcode*.app | sort -Vr)

                  if [[ "$FOUND_XCODE" == "" ]]
                  then
                    echo "No installed Xcode matched Swift $REQUESTED_SWIFT."
                    echo "Detected toolchains:"
                    while read -r APP
                    do
                      DEV_DIR="$APP/Contents/Developer"
                      XCODE_VERSION=$(DEVELOPER_DIR="$DEV_DIR" xcodebuild -version 2>/dev/null | awk '/^Xcode / {print $2; exit}')
                      SWIFT_VERSION=$(DEVELOPER_DIR="$DEV_DIR" xcrun swift --version 2>/dev/null | head -n 1 | sed -E 's/.*version ([0-9]+\\.[0-9]+).*/\\1/')
                      echo "  Xcode $XCODE_VERSION -> Swift $SWIFT_VERSION"
                    done < <(ls -d /Applications/Xcode*.app | sort -Vr)
                    exit 1
                  fi

                  echo "version=$FOUND_XCODE" >> "$GITHUB_OUTPUT"
              - name: Select Xcode Version
                uses: maxim-lobanov/setup-xcode@v1
                with:
                  xcode-version: ${{ steps.resolve-xcode.outputs.version }}
              - name: Xcode Version
                run: |
                  xcodebuild -version
                  swift --version
      """
    )
  }

  fileprivate func containerYAML(
    _ yaml: inout String, _ compiler: Compiler, _ xcodeToolchain: inout String?,
    _ xcodeVersion: inout String?
  ) {
    switch id {
      case .linux:
        yaml.append(
          """

                  runs-on: ubuntu-22.04
          """
        )

      default:
        let macosImage: String
        switch compiler.mac {
          case .xcode(let version, let image):
            xcodeVersion = version
            macosImage = image

          case .toolchain(let version, let branch, let image):
            xcodeVersion = version
            xcodeToolchain = branch
            macosImage = image
            yaml.append(
              """

                      env:
                          TOOLCHAINS: swift
              """
            )
        }

        yaml.append(
          """

                  runs-on: \(macosImage)
          """
        )

    }
  }

  fileprivate func commonYAML(_ yaml: inout String) {
    yaml.append(
      """

              steps:
              - name: Checkout
                uses: actions/checkout@v4
      """
    )

    if (id == .macOS) || !subPlatforms.isEmpty {
      yaml.append(
        """

                - name: Install xcbeautify
                  run: brew install xcbeautify
        """
      )
    }
  }

  fileprivate func makeLogsYAML(_ yaml: inout String) {
    yaml.append(
      """

              - name: Make Logs Directory
                run: mkdir logs
      """
    )
  }

}
