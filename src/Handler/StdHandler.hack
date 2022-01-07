namespace HackLogging\Handler;

use namespace HackLogging;
use namespace HH\Lib\IO;

class StdHandler extends AbstractProcessingHandler {
  public function __construct(
    private IO\WriteHandle $writeHandler,
    protected HackLogging\LogLevel $level = HackLogging\LogLevel::DEBUG,
    protected bool $bubble = true,
  )[] {
    parent::__construct($level, $bubble);
  }

  <<__Override>>
  public async function closeAsync(): Awaitable<void> {
    $handler = $this->writeHandler;
    if($handler is IO\CloseableWriteHandle) {
      return $handler->close();
    }
    return;
  }

  <<__Override>>
  protected function writeAsync(
    HackLogging\RecordShape $record,
  ): Awaitable<void> {
    $formatted = Shapes::idx($record, 'formatted', '');
    return $this->writeHandler->writeAllAsync($formatted);
  }
}
