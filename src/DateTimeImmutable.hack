namespace HackLogging;

use type DateTimeZone;

final class DateTimeImmutable extends \DateTimeImmutable implements \JsonSerializable {

  public function __construct(
    private bool $useMicroseconds = false,
    ?DateTimeZone $timezone = null
  ) {
    parent::__construct('now', $timezone);
  }

  public function jsonSerialize(): string {
    if ($this->useMicroseconds) {
      return $this->format('Y-m-d\TH:i:s.uP');
    }
    return $this->format('Y-m-d\TH:i:sP');
  }

  public function __toString(): string {
    return $this->jsonSerialize();
  }
}
