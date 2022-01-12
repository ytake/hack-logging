namespace HackLogging;

use namespace HH\Lib\Str;
use type DateTimeZone;
use function microtime;

final class DateTimeImmutable extends \DateTimeImmutable implements \JsonSerializable {
  public function __construct(
    private bool $useMicroseconds = false,
    ?DateTimeZone $timezone = null,
  )[rx] {
    if ($this->useMicroseconds) {
      $tmp = new \DateTimeImmutable('now', $timezone);
      $microtime = microtime(true);
      parent::__construct(
        Str\format(
          '%s.%06d',
          $tmp->format('Y-m-d H:i:s'),
          ($microtime - ((int)$microtime))*1e6,
        ),
        $timezone,
      );
    } else {
      parent::__construct('now', $timezone);
    }
  }

  public function jsonSerialize()[rx]: string {
    if ($this->useMicroseconds) {
      return $this->format('Y-m-d\TH:i:s.uP');
    }
    return $this->format('Y-m-d\TH:i:sP');
  }

  public function toString()[rx]: string {
    return $this->jsonSerialize();
  }
}
