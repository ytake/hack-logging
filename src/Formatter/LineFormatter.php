<?hh // strict

namespace HackLogging\Formatter;

use type HackLogging\RecordShape;
use type HackLogging\DateTimeImmutable;
use namespace HH\Lib\{Vec, Str};
use function strval;
use function var_export;
use function is_scalar;

class LineFormatter extends AbstractFormatter {

  const string SIMPLE_FORMAT = "[%datetime%] %channel%.%level_name%: %message% %context% %extra%\n";
  
  public function __construct(
    protected string $format = static::SIMPLE_FORMAT,
    string $dateFormat = static::SIMPLE_DATE,
    protected bool $allowInlineLineBreaks = false
  ) {
    parent::__construct($dateFormat);
  }

  public function message(RecordShape $record): string {
    $record = $this->format($record);
    $output = $this->format;
    foreach (Shapes::idx($record, 'extra', dict[]) as $var => $val) {
      if (Str\search($output, '%extra.'.$var.'%') is nonnull) {
        $output = Str\replace($output, '%extra.'.$var.'%', $this->stringify($val));
      }
    }
    foreach (Shapes::idx($record, 'context', dict[]) as $var => $val) {
      if (Str\search($output, '%context.'.$var.'%') is nonnull) {
        $output = Str\replace($output, '%context.'.$var.'%', $this->stringify($val));
      }
    }
    foreach ($record as $var => $val) {
      if (false !== strpos($output, '%'.$var.'%')) {
        $output = str_replace('%'.$var.'%', $this->stringify($val), $output);
      }
    }

        // remove leftover %extra.xxx% and %context.xxx% if any
        if (false !== strpos($output, '%')) {
            $output = preg_replace('/%(?:extra|context)\..+?%/', '', $output);
        }

        return $output;
  }

  protected function convertToString(mixed $data): string {
    if (!$data is nonnull || $data is bool) {
      return \var_export($data, true);
    }
    if (is_scalar($data)) {
      return strval($data);
    }
    return $this->toJson($data);
  }

  public function stringify(mixed $value): string {
    return $this->replaceNewlines($this->convertToString($value));
  }

  <<__Rx>>
  protected function replaceNewlines(string $str): string {
    if ($this->allowInlineLineBreaks) {
      if (0 === Str\search($str, '{')) {
        return Str\replace_every($str, dict[
          '\r' => "\r",
          '\n' => "\n"
        ]);
      }
      return $str;
    }
    return Str\replace_every($str, dict[
      "\r\n" => ' ',
      "\r" => ' ',
      "\n" => ' '
    ]);
  }
}
