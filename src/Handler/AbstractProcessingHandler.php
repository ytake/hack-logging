<?hh // strict

namespace HackLogging\Handler;

use type HackLogging\RecordShape;
use type HackLogging\Formatter\FormatterInterface;

abstract class AbstractProcessingHandler extends AbstractHandler 
  implements ProcessableHandlerInterface, FormattableHandlerInterface {

  use ProcessableHandlerTrait;
  use FormattableHandlerTrait;

  public function handle(RecordShape $record): bool {
    if (!$this->isHandling($record)) {
      return false;
    }

    if ($this->processors) {
      $record = $this->processRecord($record);
    }

    $record['formatted'] = $this->getFormatter()->format($record);
    $this->write($record);
    return false === $this->bubble;
  }

  abstract protected function write(RecordShape $record): void;

  public function reset(): void {
    parent::reset();
    $this->resetProcessors();
  }
}
