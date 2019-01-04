<?hh // strict

namespace HackLogging\Handler;

use type HackLogging\RecordShape;
use type HackLogging\ResettableInterface;
use type HackLogging\Processor\ProcessorInterface;
use namespace HH\Lib\{C, Vec, Str};

trait ProcessableHandlerTrait {
  require implements ProcessableHandlerInterface;

  protected vec<ProcessorInterface> $processors = vec[];

  public function pushProcessor(
    ProcessorInterface $processor
  ): void {
    $this->processors = Vec\concat(vec[$processor], $this->processors);
  }

  public function popProcessor(): ProcessorInterface {
    $processor = C\firstx($this->processors);
    $this->processors = Vec\drop($this->processors, 1);
    return $processor;
  }

  protected function processRecord(RecordShape $record): RecordShape {
    foreach ($this->processors as $processor) {
      $record = $processor->invoke($record);
    }
    return $record;
  }

  protected function resetProcessors(): void {
    foreach ($this->processors as $processor) {
      if ($processor is ResettableInterface) {
        $processor->reset();
      }
    }
  }
}
