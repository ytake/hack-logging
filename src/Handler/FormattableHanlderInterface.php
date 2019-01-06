<?hh // strict

namespace HackLogging\Handler;

use type HackLogging\Formatter\FormatterInterface;

interface FormattableHandlerInterface {

  public function setFormatter(
    FormatterInterface $formatte
  ): void;

  public function getFormatter(): FormatterInterface;
}
