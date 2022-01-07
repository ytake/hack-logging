namespace HackLogging\Formatter;

use type HackLogging\RecordShape;
use namespace HH\Lib\{Regex, Str};
use function strval;
use function is_scalar;
use function var_export;

class LineFormatter extends AbstractFormatter {
  const string SIMPLE_FORMAT = "[%datetime%] %channel%.%level_name%: %message% %context% %extra%\n";

  public function __construct(
    protected string $format = static::SIMPLE_FORMAT,
    string $dateFormat = static::SIMPLE_DATE,
    protected bool $allowInlineLineBreaks = false
  )[] {
    parent::__construct($dateFormat);
  }

  <<__Override>>
  public function format(RecordShape $record)[rx]: string {
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
    foreach (Shapes::toDict($record) as $var => $val) {
      if (Str\search($output, '%'.$var.'%') is nonnull) {
        if ($val is \DateTimeImmutable) {
          $val = $this->formatDate($val);
        }
        $output = Str\replace($output, '%'.$var.'%', $this->stringify($val));
      }
    }
    if (Str\search($output, '%') is nonnull) {
      $output = Regex\replace($output, re"/%(?:extra|context)\..+?%/", '');
    }
    return $output;
  }

  protected function convertToString(mixed $data)[rx]: string {
    if (!$data is nonnull || $data is bool) {
      return var_export($data, true);
    }
    if (is_scalar($data)) {
      return strval($data);
    }
    return $this->toJson($data);
  }

  public function stringify(mixed $value)[rx]: string {
    return $this->replaceNewlines($this->convertToString($value));
  }

  protected function replaceNewlines(string $str)[]: string {
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
