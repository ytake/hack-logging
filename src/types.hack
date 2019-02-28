namespace HackLogging;

use type Usox\Log\{LogLevel, LogLevelName};

type RecordShape = shape(
  ?'message' => string,
  ?'context' => dict<arraykey, mixed>,
  'level' => LogLevel,
  ?'level_name' => LogLevelName,
  'channel' => string,
  ?'datetime' => \DateTimeInterface,
  ?'extra' => dict<arraykey, mixed>,
  ?'formatted' => string,
);
