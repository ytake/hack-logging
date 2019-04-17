namespace HackLogging\Formatter;

use type HackLogging\RecordShape;
use type HackLogging\DateTimeImmutable;
use namespace HH\Lib\{Vec, Regex, Str};
use function json_encode;
use function json_last_error;
use function utf8_encode;
use function var_export;
use const JSON_UNESCAPED_SLASHES;
use const JSON_UNESCAPED_UNICODE;
use const JSON_PRESERVE_ZERO_FRACTION;
use const JSON_ERROR_UTF8;
use const JSON_ERROR_CTRL_CHAR;
use const JSON_ERROR_STATE_MISMATCH;
use const JSON_ERROR_DEPTH;

abstract class AbstractFormatter implements FormatterInterface {

  const string SIMPLE_DATE = "Y-m-d\TH:i:sP";

  protected int $maxNormalizeDepth = 9;
  protected int $maxNormalizeItemCount = 1000;

  private int $jsonEncodeOptions = JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_PRESERVE_ZERO_FRACTION;
  public function __construct(
    protected string $dateFormat = static::SIMPLE_DATE,
  ) {}

  abstract public function format(RecordShape $record): string;

  public function formatBatch(vec<RecordShape> $records): vec<string> {
    return Vec\map($records, ($row) ==> $this->format($row));
  }

  public function getMaxNormalizeDepth(): int {
    return $this->maxNormalizeDepth;
  }

  public function setMaxNormalizeDepth(int $maxNormalizeDepth): this {
    $this->maxNormalizeDepth = $maxNormalizeDepth;
    return $this;
  }

  public function getMaxNormalizeItemCount(): int {
    return $this->maxNormalizeItemCount;
  }

  public function setMaxNormalizeItemCount(int $maxNormalizeItemCount): this {
    $this->maxNormalizeItemCount = $maxNormalizeItemCount;
    return $this;
  }

  public function setJsonPrettyPrint(bool $enable): this {
    if ($enable) {
        $this->jsonEncodeOptions |= \JSON_PRETTY_PRINT;
        return $this;
    }
    $this->jsonEncodeOptions ^= \JSON_PRETTY_PRINT;
    return $this;
  }

  private function jsonEncode(mixed $data): mixed {
    return json_encode($data, $this->jsonEncodeOptions);
  }

  protected function toJson(mixed $data): string {
    $json = $this->jsonEncode($data);
    if ($json === false) {
      $json = $this->handleJsonError(json_last_error(), $data);
    }
    return (string) $json;
  }

  private function handleJsonError(int $code, mixed $data): string {
    if ($code !== JSON_ERROR_UTF8) {
      throw $this->throwEncodeError($code, $data);
    }
    if ($data is string) {
      $this->detectAndCleanUtf8($data);
    } elseif ($data is Traversable<_>) {
      $data = Vec\map(
        $data,
        ($element) ==> {
          $element as string;
          return $this->detectAndCleanUtf8($element);
        }
      );
    } else {
      throw $this->throwEncodeError($code, $data);
    }
    $json = $this->jsonEncode($data);
    if($json is string) {
      return $json;
    }
    throw $this->throwEncodeError(json_last_error(), $data);
  }

  public function detectAndCleanUtf8(string $data): string {
    if (!Regex\matches($data, re"//u")) {
      return Regex\replace_with($data, re"/[\x80-\xFF]+/", ($str) ==> utf8_encode($str[0]))
        |> Str\replace_every($$, dict[
          '¤' => '€',
          '¦' => 'Š',
          '¨' => 'š',
          '´' => 'Ž',
          '¸' => 'ž',
          '¼' => 'Œ',
          '½' => 'œ',
          '¾' => 'Ÿ',
      ]);
    }
    return $data;
  }

  private function throwEncodeError(int $code, mixed $data): \RuntimeException {
    switch ($code) {
      case JSON_ERROR_DEPTH:
        $msg = 'Maximum stack depth exceeded';
        break;
      case JSON_ERROR_STATE_MISMATCH:
        $msg = 'Underflow or the modes mismatch';
        break;
      case JSON_ERROR_CTRL_CHAR:
        $msg = 'Unexpected control character found';
        break;
      case JSON_ERROR_UTF8:
        $msg = 'Malformed UTF-8 characters, possibly incorrectly encoded';
        break;
      default:
        $msg = 'Unknown error';
    }
    return new \RuntimeException(
      Str\format(
        'JSON encoding failed: %s. Encoding: %s',
        $msg,
        var_export($data, true)
      )
    );
  }

  protected function formatDate(\DateTimeInterface $date): string {
    if ($this->dateFormat === self::SIMPLE_DATE && $date is DateTimeImmutable) {
      return $date->toString();
    }
    return $date->format($this->dateFormat);
  }
}
