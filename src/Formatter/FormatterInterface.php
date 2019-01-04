<?hh // strict

namespace HackLogging\Formatter;

use HackLogging\RecordShape;

interface FormatterInterface {

  public function format(RecordShape $record): mixed;

  public function formatBatch(vec<RecordShape> $records): mixed;
}
