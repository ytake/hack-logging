namespace HackLogging\Handler;

use type HackLogging\Logger;
use type HackLogging\RecordShape;
use type Usox\Log\LogLevel;

final class NullHandler extends Handler {

  public function __construct(
    private LogLevel $logLevel = LogLevel::DEBUG
  ) {}

  public function isHandling(RecordShape $record): bool {
    return $record['level'] >= $this->logLevel;
  }

  public async function handleAsync(RecordShape $record): Awaitable<bool> {
    return ($record['level'] >= $this->logLevel);
  }
}
