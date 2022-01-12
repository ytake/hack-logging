namespace HackLogging\Handler;

use namespace HackLogging\Formatter;

trait FormattableHandlerTrait {
  require implements FormattableHandlerInterface;

  protected ?Formatter\FormatterInterface $formatter;

  public function setFormatter(
    Formatter\FormatterInterface $formatter,
  )[write_props]: void {
    $this->formatter = $formatter;
  }

  public function getFormatter()[write_props]: Formatter\FormatterInterface {
    if (!$this->formatter) {
      $this->formatter = $this->getDefaultFormatter();
    }
    return $this->formatter;
  }

  protected function getDefaultFormatter()[]: Formatter\FormatterInterface {
    return new Formatter\LineFormatter();
  }
}
