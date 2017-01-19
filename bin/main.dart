// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:server/api/api.dart' as server;
import 'package:jaguar/jaguar.dart';
import 'package:scribe/scribe.dart';
import 'package:args/args.dart';
import 'dart:io';
import 'package:logging/logging.dart';

main(List<String> args) async {
  File f = new File('/home/teja/hello2.txt');
  try {
    final _Args parsed = parse(args);
    parsed.validate();

    server.IcuApi api = new server.IcuApi();

    Configuration conf = new Configuration(
        address: parsed.host, port: parsed.port, multiThread: true);
    conf.addApi(api);

    final loggers = [new ConsoleBackend(nonBlocking: true)];
    String file = parsed.stdoutFile ?? '';
    if (!await new File(file).exists()) {
      Directory dir = await Directory.systemTemp.createTemp('icu');
      file = dir.path + Platform.pathSeparator + 'stdout.log';
    }
    loggers.add(new RotatingLoggingBackend(file));

    final listener = new LoggingServer(loggers);
    await listener.start();
    listener.getNewTarget().bind(conf.log);

    hierarchicalLoggingEnabled = true;
    conf.log.level = Level.ALL;

    await serve(conf);
  } catch (e, s) {
    f.writeAsStringSync(e.toString());
  }
}

_Args parse(List<String> args) {
  final parser = new ArgParser();

  parser.addOption('host',
      abbr: 'h', defaultsTo: '127.0.0.1', help: 'server hostname');
  parser.addOption('port', abbr: 'p', defaultsTo: '8080', help: 'server port');
  parser.addOption('options_file',
      help: 'file with user options, in JSON format');
  parser.addOption('stdout', help: 'optional file to use for stdout');
  parser.addOption('stderr', help: 'optional file to use for stderr');
  parser.addOption('keep_logfiles',
      help: 'retain logfiles after the server exits');
  parser.addOption('log',
      help: 'log level, one of '
          '[debug|info|warning|error|critical]');
  parser.addOption('idle_suicide_seconds',
      help: 'num idle seconds before server shuts down', defaultsTo: '0');
  parser.addOption('check_interval_seconds',
      help: 'interval in seconds to check server '
          'inactivity and keep subservers alive',
      defaultsTo: '600');

  ArgResults result = parser.parse(args);

  final dynamic host = result['host'];

  final dynamic port = int.parse(result['port'], onError: (_) => 0);

  final dynamic optionsFile = result['options_file'];

  final dynamic stdoutFile = result['stdout'];

  final dynamic stderrFile = result['stderr'];

  if (host is! String) throw new Exception('Invalid host!');
  if (port == 0) throw new Exception('Invalid port!');

  return new _Args(
      host: host,
      port: port,
      optionsFile: optionsFile,
      stdoutFile: stdoutFile,
      stderrFile: stderrFile);
}

class _Args {
  final String host;

  final int port;

  final String optionsFile;

  final String stdoutFile;

  final String stderrFile;

  final bool keepLogFiles;

  _Args(
      {this.host: '127.0.0.1',
      this.port: 8080,
      this.optionsFile,
      this.stdoutFile,
      this.stderrFile,
      this.keepLogFiles});

  void validate() {
    if (host is! String) {
      throw new Exception('Invalid host!');
    }

    if (port is! int || port <= 0) {
      throw new Exception('Invalid port!');
    }
  }
}
