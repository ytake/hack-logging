<?hh // strict

namespace HackLogging\Handler;

use HackLogging\Logger;
use HackLogging\LogLevel;
use HackLogging\RecordShape;

final class NullHandler extends Handler {

  public function __construct(
    private LogLevel $logLevel
  ) {}

  public function isHandling(RecordShape $record): bool {
    return $record['level'] >= $this->logLevel;
  }

  public function handle(RecordShape $record): bool {
    return $record['level'] >= $this->logLevel;
  }
}
