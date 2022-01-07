namespace HackLogging\Formatter;

use type HackLogging\RecordShape;

interface FormatterInterface {
  public function format(
    RecordShape $record,
  )[rx]: string;

  public function formatBatch(
    vec<RecordShape> $records,
  )[rx]: vec<string>;
}
