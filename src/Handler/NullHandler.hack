namespace HackLogging\Handler;

use namespace HackLogging;

final class NullHandler extends Handler {

  public function __construct(
    private HackLogging\LogLevel $logLevel = HackLogging\LogLevel::DEBUG
  )[] {}

  <<__Override>>
  public function isHandling(
    HackLogging\RecordShape $record,
  )[]: bool {
    return $record['level'] >= $this->logLevel;
  }

  <<__Override>>
  public async function handleAsync(
    HackLogging\RecordShape $record,
  )[]: Awaitable<bool> {
    return $record['level'] >= $this->logLevel;
  }
}
