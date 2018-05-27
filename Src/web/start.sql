CREATE TABLE IF NOT EXISTS tbl_reports (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  UserID VARCHAR(255),
  Object VARCHAR(80),
  Message VARCHAR(255),
  Stack TEXT
);

CREATE INDEX idx_UserID ON tbl_reports (UserID);

CREATE INDEX idx_Object ON tbl_reports (Object);

CREATE INDEX idx_Message ON tbl_reports (Message);