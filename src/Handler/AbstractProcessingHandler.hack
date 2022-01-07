namespace HackLogging\Handler;

use type HackLogging\RecordShape;

abstract class AbstractProcessingHandler extends AbstractHandler
  implements FormattableHandlerInterface {

  use FormattableHandlerTrait;

  <<__Override>>
  public async function handleAsync(
    RecordShape $record,
  )[rx, write_props]: Awaitable<bool> {
    if (!$this->isHandling($record)) {
      return false;
    }

    $record['formatted'] = $this->getFormatter()->format($record);
    await $this->writeAsync($record);
    return false === $this->bubble;
  }

  protected async function writeAsync(
    RecordShape $_record,
  ): Awaitable<void> {
    return;
  }

  <<__Override>>
  public function reset()[]: void {
    parent::reset();
  }
}
