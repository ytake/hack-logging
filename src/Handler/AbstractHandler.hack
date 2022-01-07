namespace HackLogging\Handler;

use namespace HackLogging;

abstract class AbstractHandler extends Handler implements HackLogging\ResettableInterface {

  public function __construct(
    protected HackLogging\LogLevel $level = HackLogging\LogLevel::DEBUG,
    protected bool $bubble = true,
  )[] {
    // TODO ??!?!
    $this->bubble = $bubble;
  }

  <<__Override>>
  public function isHandling(
    HackLogging\RecordShape $record,
  )[]: bool {
    return $record['level'] >= $this->level;
  }

  public function getLevel()[]: HackLogging\LogLevel {
    return $this->level;
  }

  public function setBubble(
    bool $bubble,
  )[write_props]: void {
    $this->bubble = $bubble;
  }

  public function getBubble()[]: bool {
    return $this->bubble;
  }

  public function reset()[]: void {
  }
}
