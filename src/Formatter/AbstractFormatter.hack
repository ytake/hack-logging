namespace HackLogging\Formatter;

use namespace HackLogging;
use namespace HH\Lib\{Regex, Str, Vec};
use type DateTimeInterface;
use type RuntimeException;
use function json_encode_with_error;
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
  const string SIMPLE_DATE = 'Y-m-d\\TH:i:sP';

  protected int $maxNormalizeDepth = 9;
  protected int $maxNormalizeItemCount = 1000;

  private int $jsonEncodeOptions = JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_PRESERVE_ZERO_FRACTION;

  public function __construct(
    protected string $dateFormat = static::SIMPLE_DATE,
  )[] {}

  abstract public function format(
    HackLogging\RecordShape $record,
  )[rx]: string;

  public function formatBatch(
    vec<HackLogging\RecordShape> $records,
  )[rx]: vec<string> {
    return Vec\map($records, ($row) ==> $this->format($row));
  }

  public function getMaxNormalizeDepth()[]: int {
    return $this->maxNormalizeDepth;
  }

  public function setMaxNormalizeDepth(
    int $maxNormalizeDepth,
  )[write_props]: this {
    $this->maxNormalizeDepth = $maxNormalizeDepth;
    return $this;
  }

  public function getMaxNormalizeItemCount()[]: int {
    return $this->maxNormalizeItemCount;
  }

  public function setMaxNormalizeItemCount(
    int $maxNormalizeItemCount,
  )[write_props]: this {
    $this->maxNormalizeItemCount = $maxNormalizeItemCount;
    return $this;
  }

  public function setJsonPrettyPrint(
    bool $enable,
  )[write_props]: this {
    if ($enable) {
        $this->jsonEncodeOptions |= \JSON_PRETTY_PRINT;
        return $this;
    }
    $this->jsonEncodeOptions ^= \JSON_PRETTY_PRINT;
    return $this;
  }

  private function jsonEncode(
    mixed $data,
    inout ?(int, string) $error,
  )[rx]: mixed {
    return json_encode_with_error(
      $data,
      inout $error,
      $this->jsonEncodeOptions,
    );
  }

  protected function toJson(
    mixed $data,
  )[rx]: string {
    $error = null;
    $json = $this->jsonEncode(
      $data,
      inout $error,
    );
    if ($json === false) {
      $json = $this->handleJsonError(
        $error,
        $data,
      );
    }
    return (string) $json;
  }

  private function handleJsonError(
    ?(int, string) $error,
    mixed $data,
  )[rx]: string {
    if($error !== null) {
      if ($error[0] !== JSON_ERROR_UTF8) {
        throw $this->throwEncodeError($error, $data);
      }
      if ($data is string) {
        $this->detectAndCleanUtf8($data);
      } else if ($data is Traversable<_>) {
        $data = Vec\map(
          $data,
          ($element) ==> {
            $element as string;
            return $this->detectAndCleanUtf8($element);
          }
        );
      } else {
        throw $this->throwEncodeError($error, $data);
      }
      $error = null;
      $json = $this->jsonEncode(
        $data,
        inout $error,
      );
      if($json is string) {
        return $json;
      }
    }

    throw $this->throwEncodeError($error, $data);
  }

  public function detectAndCleanUtf8(
    string $data,
  )[]: string {
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

  private function throwEncodeError(
    ?(int, string) $error,
    mixed $data,
  )[rx]: RuntimeException {
    if($error !== null) {
      switch ($error) {
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
    } else {
      $msg = 'Unknown error';
    }
    return new RuntimeException(
      Str\format(
        'JSON encoding failed: %s. Encoding: %s',
        $msg,
        var_export($data, true),
      )
    );
  }

  protected function formatDate(
    DateTimeInterface $date,
  )[rx]: string {
    if ($this->dateFormat === self::SIMPLE_DATE && $date is HackLogging\DateTimeImmutable) {
      return $date->toString();
    }
    return $date->format($this->dateFormat);
  }
}
