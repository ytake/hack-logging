namespace HackLogging\Handler;

use type HackLogging\LogLevel;
use type HackLogging\RecordShape;

final class NullHandler extends Handler {

  public function __construct(
    private LogLevel $logLevel = LogLevel::DEBUG
  ) {}

  <<__Override>>
  public function isHandling(RecordShape $record): bool {
    return $record['level'] >= $this->logLevel;
  }

  <<__Override>>
  public async function handleAsync(RecordShape $record): Awaitable<bool> {
    return ($record['level'] >= $this->logLevel);
  }
}
