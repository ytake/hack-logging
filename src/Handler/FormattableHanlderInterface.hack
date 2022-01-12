namespace HackLogging\Handler;

use type HackLogging\Formatter\FormatterInterface;

interface FormattableHandlerInterface {

  public function setFormatter(
    FormatterInterface $formatte
  )[write_props]: void;

  public function getFormatter()[write_props]: FormatterInterface;
}
