<?hh // strict

namespace HackLogging\Formatter;

use type HackLogging\RecordShape;

interface FormatterInterface {

  public function format(RecordShape $record): string;

  public function formatBatch(vec<RecordShape> $records): vec<string>;
}
