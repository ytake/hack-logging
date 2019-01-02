<?hh // strict

namespace HackLogging;

enum LogLevel: int as int {
  DEBUG = 100;
  INFO = 200;
  NOTICE = 250;
  WARNING = 300;
  ERROR = 400;
  CRITICAL = 500;
  ALERT = 550;
  EMERGENCY = 600;
}

enum LogLevelName: string {
  DEBUG = 'DEBUG';
  INFO = 'INFO';
  NOTICE = 'NOTICE';
  WARNING = 'WARNING';
  ERROR = 'ERROR';
  CRITICAL = 'CRITICAL';
  ALERT = 'ALERT';
  EMERGENCY = 'EMERGENCY';
}

type RecordShape = shape(
  ?'message' => string,
  ?'context' => dict<arraykey, mixed>,
  'level' => LogLevel,
  ?'level_name' => LogLevelName,
  'channel' => string,
  ?'datetime' => DateTimeImmutable,
  ?'extra' => dict<arraykey, mixed>,
);
