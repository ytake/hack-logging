<?hh // strict

namespace HackLogging\Handler;

use type HackLogging\Formatter\FormatterInterface;

trait FormattableHandlerTrait {
  require implements FormattableHandlerInterface;

  protected ?FormatterInterface $formatter;

  public function setFormatter(FormatterInterface $formatter): void {
    $this->formatter = $formatter;
  }

  public function getFormatter(): FormatterInterface {
    if (!$this->formatter) {
      $this->formatter = $this->getDefaultFormatter();
    }
    return $this->formatter;
  }

  protected function getDefaultFormatter(): FormatterInterface {
    return new LineFormatter();
  }
}
