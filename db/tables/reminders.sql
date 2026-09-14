CREATE TABLE reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) NOT NULL,
  description VARCHAR(400),
  is_active BOOLEAN NOT NULL,
  date TIMESTAMPTZ NOT NULL,
  urgency_id INTEGER NOT NULL REFERENCES catalog(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_reminders_name_not_empty CHECK (char_length(TRIM(name)) > 0)
);

CREATE TABLE reminder_proposals (
  reminder_id UUID NOT NULL REFERENCES reminders(id) ON DELETE CASCADE,
  proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (reminder_id, proposal_id)
);

CREATE INDEX idx_reminders_urgency_id ON reminders(urgency_id);
CREATE INDEX idx_reminders_date ON reminders(date);
CREATE INDEX idx_reminder_proposals_proposal_id ON reminder_proposals(proposal_id);

CREATE TRIGGER trg_reminders_updated_at
BEFORE UPDATE ON reminders
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
