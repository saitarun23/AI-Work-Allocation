-- V1: core tables for the work allocation system (MySQL 8, InnoDB).
--
-- DESIGN RULE: this file creates STRUCTURE ONLY. It inserts no business values.
-- Technologies, levels, complexity categories, capacity numbers, clients, employees,
-- holidays and settings are all DATA that is added and changed later through the admin APIs
-- (or an Excel import). Nothing here, and no Java code, hard-codes them.
-- Only workflow states (batch / plan / assignment status) are fixed, because the program logic depends on them.

-- ---------------------------------------------------------------- master data

CREATE TABLE technologies (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    code        VARCHAR(40)  NOT NULL,
    name        VARCHAR(100) NOT NULL,
    active      BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_technologies_code UNIQUE (code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- rank_order: higher number = more senior. Used by complexity_categories.min_level_rank.
CREATE TABLE employee_levels (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    code        VARCHAR(40)  NOT NULL,
    name        VARCHAR(100) NOT NULL,
    rank_order  INT          NOT NULL,
    active      BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_employee_levels_code UNIQUE (code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- Difficulty categories belong to a technology, so each technology can have its own set.
-- min_level_rank: lowest employee level rank allowed to do this category (NULL = anyone).
CREATE TABLE complexity_categories (
    id              BIGINT       NOT NULL AUTO_INCREMENT,
    technology_id   BIGINT       NOT NULL,
    code            VARCHAR(40)  NOT NULL,
    name            VARCHAR(100) NOT NULL,
    sort_order      INT          NOT NULL,
    min_level_rank  INT          NULL,
    active          BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_complexity_tech_code UNIQUE (technology_id, code),
    CONSTRAINT fk_complexity_technology FOREIGN KEY (technology_id) REFERENCES technologies (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE clients (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    name        VARCHAR(150) NOT NULL,
    active      BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_clients_name UNIQUE (name)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- Behaviour settings changed from the admin screen, for example approval mode or maximum pages per work unit.
CREATE TABLE app_settings (
    setting_key    VARCHAR(100) NOT NULL,
    setting_value  VARCHAR(500) NOT NULL,
    description    VARCHAR(255) NULL,
    updated_at     DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (setting_key)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE holidays (
    id            BIGINT       NOT NULL AUTO_INCREMENT,
    holiday_date  DATE         NOT NULL,
    name          VARCHAR(150) NULL,
    PRIMARY KEY (id),
    CONSTRAINT uq_holidays_date UNIQUE (holiday_date)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- ---------------------------------------------------------------- people

CREATE TABLE employees (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    name        VARCHAR(150) NOT NULL,
    email       VARCHAR(190) NULL,
    active      BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_employees_email UNIQUE (email)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- One row per technology an employee can work on, each with its own level.
-- A person can have several skills. speed_factor is a multiplier on the capacity rule:
-- 1.00 = normal speed (neutral), 0.80 = slower, 1.20 = faster. The weekly learning step can update it from real results.
CREATE TABLE employee_skills (
    id             BIGINT       NOT NULL AUTO_INCREMENT,
    employee_id    BIGINT       NOT NULL,
    technology_id  BIGINT       NOT NULL,
    level_id       BIGINT       NOT NULL,
    speed_factor   DECIMAL(5,2) NOT NULL DEFAULT 1.00,
    active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at     DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_skill_employee_technology UNIQUE (employee_id, technology_id),
    CONSTRAINT fk_skills_employee FOREIGN KEY (employee_id) REFERENCES employees (id),
    CONSTRAINT fk_skills_technology FOREIGN KEY (technology_id) REFERENCES technologies (id),
    CONSTRAINT fk_skills_level FOREIGN KEY (level_id) REFERENCES employee_levels (id),
    CONSTRAINT ck_skills_speed CHECK (speed_factor > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE INDEX idx_skills_team ON employee_skills (technology_id, level_id, active);

CREATE TABLE employee_leaves (
    id           BIGINT      NOT NULL AUTO_INCREMENT,
    employee_id  BIGINT      NOT NULL,
    leave_date   DATE        NOT NULL,
    created_at   DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_leave_employee_date UNIQUE (employee_id, leave_date),
    CONSTRAINT fk_leaves_employee FOREIGN KEY (employee_id) REFERENCES employees (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- ---------------------------------------------------------------- capacity rules

-- Pages per day for a technology, complexity and level.
--   client_id NULL       = default rule for every client
--   client_id set        = override for that client only (wins over the default)
--   effective_from / to  = the rule applies in that date range, so changing a number keeps the history
-- To change a number: set effective_to on the old row and insert a new row with a new effective_from.
-- client_scope is a generated helper column so the unique key also works for default rows (NULL client).
CREATE TABLE capacity_rules (
    id              BIGINT       NOT NULL AUTO_INCREMENT,
    technology_id   BIGINT       NOT NULL,
    complexity_id   BIGINT       NOT NULL,
    level_id        BIGINT       NOT NULL,
    client_id       BIGINT       NULL,
    pages_per_day   INT          NOT NULL,
    effective_from  DATE         NOT NULL,
    effective_to    DATE         NULL,
    note            VARCHAR(255) NULL,
    created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    client_scope    BIGINT AS (IFNULL(client_id, 0)) STORED,
    PRIMARY KEY (id),
    CONSTRAINT uq_capacity_rule UNIQUE (technology_id, complexity_id, level_id, client_scope, effective_from),
    CONSTRAINT fk_capacity_technology FOREIGN KEY (technology_id) REFERENCES technologies (id),
    CONSTRAINT fk_capacity_complexity FOREIGN KEY (complexity_id) REFERENCES complexity_categories (id),
    CONSTRAINT fk_capacity_level FOREIGN KEY (level_id) REFERENCES employee_levels (id),
    CONSTRAINT fk_capacity_client FOREIGN KEY (client_id) REFERENCES clients (id),
    CONSTRAINT ck_capacity_pages CHECK (pages_per_day > 0),
    CONSTRAINT ck_capacity_dates CHECK (effective_to IS NULL OR effective_to >= effective_from)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE INDEX idx_capacity_lookup ON capacity_rules (technology_id, complexity_id, level_id, client_id, effective_from);

-- ---------------------------------------------------------------- work

CREATE TABLE batches (
    id             BIGINT      NOT NULL AUTO_INCREMENT,
    client_id      BIGINT      NOT NULL,
    technology_id  BIGINT      NOT NULL,
    total_pages    INT         NOT NULL,
    received_at    DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    deadline       DATE        NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'NEW',
    created_at     DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_batches_client FOREIGN KEY (client_id) REFERENCES clients (id),
    CONSTRAINT fk_batches_technology FOREIGN KEY (technology_id) REFERENCES technologies (id),
    CONSTRAINT ck_batches_pages CHECK (total_pages > 0),
    CONSTRAINT ck_batches_status CHECK (status IN ('NEW', 'CLASSIFIED', 'PLANNED', 'APPROVED', 'IN_PROGRESS', 'DONE'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE INDEX idx_batches_client ON batches (client_id);
CREATE INDEX idx_batches_status_deadline ON batches (status, deadline);

CREATE TABLE work_units (
    id             BIGINT      NOT NULL AUTO_INCREMENT,
    batch_id       BIGINT      NOT NULL,
    page_from      INT         NOT NULL,
    page_to        INT         NOT NULL,
    pages          INT         NOT NULL,
    complexity_id  BIGINT      NOT NULL,
    created_at     DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_work_units_batch FOREIGN KEY (batch_id) REFERENCES batches (id),
    CONSTRAINT fk_work_units_complexity FOREIGN KEY (complexity_id) REFERENCES complexity_categories (id),
    CONSTRAINT ck_work_units_range CHECK (page_to >= page_from),
    CONSTRAINT ck_work_units_pages CHECK (pages > 0)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE INDEX idx_work_units_batch ON work_units (batch_id);

-- A plan is one proposed allocation for a batch. A re-plan creates a new plan with a higher version.
CREATE TABLE allocation_plans (
    id           BIGINT       NOT NULL AUTO_INCREMENT,
    batch_id     BIGINT       NOT NULL,
    version      INT          NOT NULL DEFAULT 1,
    status       VARCHAR(20)  NOT NULL DEFAULT 'DRAFT',
    summary      TEXT         NULL,
    approved_by  VARCHAR(150) NULL,
    approved_at  DATETIME(6)  NULL,
    created_at   DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_plan_batch_version UNIQUE (batch_id, version),
    CONSTRAINT fk_plans_batch FOREIGN KEY (batch_id) REFERENCES batches (id),
    CONSTRAINT ck_plans_status CHECK (status IN ('DRAFT', 'APPROVED', 'REJECTED', 'SUPERSEDED'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE TABLE assignments (
    id             BIGINT      NOT NULL AUTO_INCREMENT,
    plan_id        BIGINT      NOT NULL,
    work_unit_id   BIGINT      NOT NULL,
    employee_id    BIGINT      NOT NULL,
    planned_pages  INT         NOT NULL,
    actual_pages   INT         NOT NULL DEFAULT 0,
    planned_date   DATE        NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'PLANNED',
    created_at     DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at     DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_assignments_plan FOREIGN KEY (plan_id) REFERENCES allocation_plans (id),
    CONSTRAINT fk_assignments_work_unit FOREIGN KEY (work_unit_id) REFERENCES work_units (id),
    CONSTRAINT fk_assignments_employee FOREIGN KEY (employee_id) REFERENCES employees (id),
    CONSTRAINT ck_assignments_planned CHECK (planned_pages > 0),
    CONSTRAINT ck_assignments_actual CHECK (actual_pages >= 0),
    CONSTRAINT ck_assignments_status CHECK (status IN ('PLANNED', 'IN_PROGRESS', 'DONE', 'CANCELLED'))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

CREATE INDEX idx_assignments_plan ON assignments (plan_id);
CREATE INDEX idx_assignments_work_unit ON assignments (work_unit_id);
CREATE INDEX idx_assignments_employee_date ON assignments (employee_id, planned_date);