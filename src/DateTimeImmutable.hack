namespace HackLogging;

use type DateTimeZone;

final class DateTimeImmutable extends \DateTimeImmutable implements \JsonSerializable {
  public function __construct(
    private bool $useMicroseconds = false,
    ?DateTimeZone $timezone = null,
  )[rx] {
    parent::__construct('now', $timezone);
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
