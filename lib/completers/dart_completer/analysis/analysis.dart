library dart_analyser_client;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart' as path;

class AnalyzerConfig {
  bool useChecked = false;

  bool startWithDiagnostics = false;

  final Directory directory;

  String get sdkPath => directory.path;

  AnalyzerConfig(this.directory);

  //TODO dart.exe for windows
  String get dartVMPath => path.join(sdkPath, 'bin', 'dart');

  String getSnapshotPath(String snapshotName) =>
      path.join(sdkPath, 'bin', 'snapshots', snapshotName);

  String getAnalysisServerSnapshotPath() =>
      getSnapshotPath(analysisServerSnapshotName);

  static const String analysisServerSnapshotName =
      'analysis_server.dart.snapshot';

  static const int diagnosticsPort = 23072;
}

class Analyzer {
  final AnalyzerConfig config;

  Process _process;

  StreamSubscription<String> _inStreamSub;

  Analyzer(this.config);

  bool get isRunning => _process != null;

  Future<Null> start() async {
    if (isRunning) {
      throw new Exception("Analyzer already running!");
    }
    _process = await _createProcess(config);
    _inStreamSub = _process.stdout
        .transform(UTF8.encoder)
        .transform(new LineSplitter())
        .listen(_processInMsg);
    //TODO connect writer
  }

  /// Restarts, or starts, the analysis server process.
  Future<Null> restart() async {
    if (isRunning) {
      await kill();
    }

    await start();
  }

  Future<Null> kill() async {
    if (isRunning) {
      _process.kill();
      _process = null;
      if (_inStreamSub is StreamSubscription) _inStreamSub.cancel();
      //TODO listener for when process terminates
    }
  }

  void _processInMsg(String msg) {
    //TODO
  }

  static Future<Process> _createProcess(AnalyzerConfig config) {
    List<String> arguments = <String>[];

    if (config.useChecked) {
      arguments.add('--checked');
    }

    if (config.startWithDiagnostics) {
      arguments.add('--enable-vm-service=0');
    }

    arguments.add(config.getAnalysisServerSnapshotPath());

    arguments.add('--sdk=${config.sdkPath}');

    // Check to see if we should start with diagnostics enabled.
    if (config.startWithDiagnostics) {
      arguments.add('--port=${AnalyzerConfig.diagnosticsPort}');
    }

    arguments.add('--client-id=icu');

    return Process.start(config.dartVMPath, arguments);
  }
}
