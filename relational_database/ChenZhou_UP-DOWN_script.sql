--czhou103
--UP/DOWN script to create tables with constraints

--DOWN
--13 foreign key constraints
if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_tokens_end_time_point_id')
alter table tokens drop constraint fk_tokens_end_time_point_id

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_tokens_start_time_point_id')
alter table tokens drop constraint fk_tokens_start_time_point_id

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_tokens_token_label_id')
alter table tokens drop constraint fk_tokens_token_label_id

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_tokens_token_level_id')
alter table tokens drop constraint fk_tokens_token_level_id

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_tokens_token_recording_id')
alter table tokens drop constraint fk_tokens_token_recording_id

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_rules_daughter3_label_id')
alter table rules drop constraint fk_rules_daughter3_label_id

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_rules_daughter2_label_id')
alter table rules drop constraint fk_rules_daughter2_label_id

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_rules_daughter1_label_id')
alter table rules drop constraint fk_rules_daughter1_label_id

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_rules_mother_label_id')
alter table rules drop constraint fk_rules_mother_label_id

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_recordings_recording_user_id')
alter table recordings drop constraint fk_recordings_recording_user_id

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_recording_time_points_recording_time_points_time_point_id')
alter table recording_time_points drop constraint fk_recording_time_points_recording_time_points_time_point_id

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_recording_time_points_recording_time_points_recording_id')
alter table recording_time_points drop constraint fk_recording_time_points_recording_time_points_recording_id

if exists (select * from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    where CONSTRAINT_NAME = 'fk_labels_label_level_id')
alter table labels drop constraint fk_labels_label_level_id

--8 tables
drop table if exists tokens
drop table if exists users
drop table if exists time_points
drop table if exists rules
drop table if exists recordings
drop table if exists recording_time_points
drop table if exists levels
drop table if exists labels
go

--UP 
create table labels (
	label_id int identity not null,
	label_name varchar(20) not null,
	label_level_id int not null,
    constraint pk_labels_label_id primary key (label_id),
    constraint u_labels_label_name unique (label_name)
    )
go
create table levels (
    level_id int identity not null,
	level_type varchar(50) not null,
    constraint pk_levels_level_id primary key (level_id),
    constraint u_levels_level_type unique (level_type)
    )
go
create table recording_time_points (
    recording_time_points_recording_id int null,
	recording_time_points_time_point_id int null,
    constraint pk_recording_time_points_recording_time_points_time_point_id unique (recording_time_points_time_point_id)
    )
GO
create table recordings (
    recording_id int identity not null,
	duration varchar(10) null,
	number_of_sounds int null,
	recording_user_id int null,
    constraint pk_recordings_recording_id primary key (recording_id)
    )
GO
create table rules (
    rule_id int identity not null,
	mother_label_id int not null,
	daughter1_label_id int null,
	daughter2_label_id int null,
	daughter3_label_id int null,
    constraint pk_rules_rule_id primary key (rule_id)
    )
go
create table time_points (
    time_point_id int identity not null,
	time_point char(4) not null,
    constraint pk_time_points_time_point_id primary key (time_point_id),
    constraint u_time_point unique (time_point)
    )
GO
create table users (
    user_id int identity not null,
	email varchar(50) NOT NULL,
	username [varchar](20) NOT NULL,
    constraint pk_users_user_id primary key ([user_id]),
    constraint u_users_email unique (email)
    )
go
create table tokens (
    token_id int identity not null,
	[sequence] int null,
	start_time_point_id int null,
    end_time_point_id int null,
    token_recording_id int null,
    token_level_id int null,
    token_label_id int null,
    token_symbol varchar(max) not null,
    constraint pk_tokens_token_id primary key (token_id)
    )
go
alter table labels
    add constraint fk_labels_label_level_id foreign key (label_level_id) references levels (level_id)
GO
alter table recording_time_points
    add constraint fk_recording_time_points_recording_time_points_recording_id foreign key (recording_time_points_recording_id) references recordings (recording_id),
        constraint fk_recording_time_points_recording_time_points_time_point_id foreign key (recording_time_points_time_point_id) references time_points (time_point_id)
GO
alter table recordings
    add constraint fk_recordings_recording_user_id foreign key (recording_user_id) references users ([user_id])
GO
alter table rules
    add constraint fk_rules_mother_label_id foreign key (mother_label_id) references labels (label_id),
        constraint fk_rules_daughter1_label_id foreign key (daughter1_label_id) references labels (label_id),
        constraint fk_rules_daughter2_label_id foreign key (daughter2_label_id) references labels (label_id),
        constraint fk_rules_daughter3_label_id foreign key (daughter3_label_id) references labels (label_id)
go
alter table tokens
    add constraint fk_tokens_token_recording_id foreign key (token_recording_id) references recordings (recording_id),
        constraint fk_tokens_token_level_id foreign key (token_level_id) references levels (level_id),
        constraint fk_tokens_token_label_id foreign key (token_label_id) references labels (label_id),
        constraint fk_tokens_start_time_point_id foreign key (start_time_point_id) references recording_time_points (recording_time_points_time_point_id),
        constraint fk_tokens_end_time_point_id foreign key (end_time_point_id) references recording_time_points (recording_time_points_time_point_id)
GO








        
