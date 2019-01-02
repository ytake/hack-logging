<?hh // strict

namespace HackLogging\Processor;

use type HackLogging\RecordShape;

interface ProcessorInterface {
  
  public function invoke(
    RecordShape $record
  ): RecordShape;
}
