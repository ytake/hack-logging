<?hh // strict

namespace HackLogging\Handler;

use type HackLogging\Formatter\FormatterInterface;

interface FormattableHandlerInterface {

  public function setFormatter(
    FormatterInterface $formatte
  ): HandlerInterface;

  public function getFormatter(): FormatterInterface;
}
