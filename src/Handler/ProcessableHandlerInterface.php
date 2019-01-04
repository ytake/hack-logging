<?hh // strict

namespace HackLogging\Handler;

use type HackLogging\Processor\ProcessorInterface;

interface ProcessableHandlerInterface {

  public function pushProcessor(
    ProcessorInterface $processor
  ): void;

  public function popProcessor(): ProcessorInterface;
}
