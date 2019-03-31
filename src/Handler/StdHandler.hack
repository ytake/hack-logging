namespace HackLogging\Handler;

use type HackLogging\LogLevel;
use type HackLogging\RecordShape;
use namespace HH\Lib\Experimental\IO;

class StdHandler extends AbstractProcessingHandler {

  public function __construct(
    private IO\WriteHandle $writeHandler,
    protected LogLevel $level = LogLevel::DEBUG,
    protected bool $bubble = true,
  ) {
    parent::__construct($level, $bubble);
  }

  <<__Override>>
  public async function closeAsync(): Awaitable<void> {
    return await $this->writeHandler->closeAsync();
  }

  <<__Override>>
  protected async function writeAsync(RecordShape $record): Awaitable<void> {
    $formatted = Shapes::idx($record, 'formatted', '');
    await $this->writeHandler->writeAsync($formatted);
  }
}
