--cahou103
--sample data
insert into time_points
    (time_point)
    VALUES
    ('5500'),
    ('5640'),
    ('5713'),
    ('5973'),
    ('6011'),
    ('6081'),
    ('6125'),
    ('6200'),
    ('6273')
go
insert into [users]
    (email, username)
    VALUES
    ('czhou103@syr.edu', 'czhou103')
GO
insert into recordings
    (recording_user_id)
    VALUES
    (1),
    (1),
    (1),
    (1)
    
GO
insert into recording_time_points
    (recording_time_points_recording_id, recording_time_points_time_point_id)
    VALUES
    (1, 1),
    (1, 2),
    (1, 3),
    (1, 4),
    (1, 5),
    (1, 6),
    (1, 7), 
    (1, 8),
    (1, 9)
GO
insert into levels
    (level_type)
    VALUES
    ('sound'),
    ('syllable structure'),
    ('syllable'),
    ('word'),
    ('part of speech'),
    ('phrase')
GO
insert into labels
    (label_name, label_level_id)
    VALUES
    ('vowel', 1),
    ('consonant', 1),
    ('onset', 2),
    ('nucleus', 2),
    ('coda', 2),
    ('sigma', 3),
    ('word', 4),
    ('noun', 5),
    ('verb', 5),
    ('adjective', 5),
    ('noun phrase', 6),
    ('verb phrase', 6),
    ('sentence', 6)
GO
insert into tokens
    (start_time_point_id, end_time_point_id, token_recording_id, token_level_id, token_label_id, token_symbol, [sequence])
    VALUES
    (1, 2, 1, 1, 1, 'ai', 1),
    (2, 3, 1, 1, 2, 'l', 2),
    (3, 4, 1, 1, 1, 'ai', 3),
    (4, 5, 1, 1, 2, 'k', 4),
    (5, 6, 1, 1, 2, 'k', 5),
    (6, 7, 1, 1, 1, 'ae', 6),
    (7, 8, 1, 1, 2, 't', 7),
    (8, 9, 1, 1, 2, 's', 8),
    (1, 2, 1, 2, 4, 'ai', 1),
    (2, 3, 1, 2, 3, 'l', 2),
    (3, 4, 1, 2, 4, 'ai', 3),
    (4, 5, 1, 2, 5, 'k', 4),
    (5, 6, 1, 2, 3, 'k', 5),
    (6, 7, 1, 2, 4, 'ae', 6),
    (7, 9, 1, 2, 5, 'ts', 7),
    (1, 2, 1, 3, 6, 'ai', 1),
    (2, 5, 1, 3, 6, 'laik', 2),
    (5, 9, 1, 3, 6, 'caets', 3),
    (1, 2, 1, 4, 7, 'I', 1),
    (2, 5, 1, 4, 7, 'like', 2), 
    (5, 9, 1, 4, 7, 'cats', 3),
    (1, 2, 1, 5, 8, 'I', 1),
    (2, 5, 1, 5, 9, 'like', 2),
    (5, 9, 1, 5, 8, 'cats', 3),
    (1, 2, 1, 6, 11, 'I', 1),
    (2, 9, 1, 6, 12, 'like cats', 2),
    (1, 9, 1, 6, 13, 'I like cats', 1)
go
insert into tokens
	([sequence], token_recording_id, token_level_id, token_label_id, token_symbol)
	values
	(1, 2, 6, 13, 'linguistics is fun'),
	(1, 3, 6, 13, 'database is useful'),
	(1, 4, 6, 13, 'procrastination is bad')
go
insert into rules
    (mother_label_id, daughter1_label_id, daughter2_label_id, daughter3_label_id)
    values
    (4, 1, null, null),
    (3, null, null, null),
    (3, 2, null, null),
    (5, 2, null, null),
    (5, 2, 2, null),
    (6, 4, null, null),
    (6, 3, 4, 5),
    (7, 6, null, null),
    (8, 7, null, null),
    (9, 7, null, null),
    (11, 8, null, null),
    (12, 9, 8, null),
    (13, 11, 12, null)