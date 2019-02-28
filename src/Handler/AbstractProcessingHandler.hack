namespace HackLogging\Handler;

use type HackLogging\RecordShape;
use type HackLogging\Formatter\FormatterInterface;

abstract class AbstractProcessingHandler extends AbstractHandler
  implements FormattableHandlerInterface {

  use FormattableHandlerTrait;

  public async function handleAsync(RecordShape $record): Awaitable<bool> {
    if (!$this->isHandling($record)) {
      return false;
    }

    $record['formatted'] = $this->getFormatter()->format($record);
    await $this->writeAsync($record);
    return false === $this->bubble;
  }

  protected async function writeAsync(RecordShape $record): Awaitable<void> {
    return;
  }

  public function reset(): void {
    parent::reset();
  }
}
