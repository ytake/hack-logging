<?hh // strict

namespace HackLogging\Formatter;

use type HackLogging\RecordShape;

interface FormatterInterface {

  public function format(RecordShape $record): RecordShape;

  public function formatBatch(vec<RecordShape> $records): vec<RecordShape>;
}
