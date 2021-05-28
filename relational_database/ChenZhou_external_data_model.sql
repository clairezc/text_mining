--czhou103
--external data models for user stories


--Display all the tokens in each level, with annotations (the one implemented in Power Apps)
select token_symbol as sounds, label_name as annotation
from tokens 
join labels on label_id = token_label_id
where token_level_id = 1 and token_recording_id = 1

select token_symbol as [syllable structures], label_name as annotation
from tokens 
join labels on label_id = token_label_id
where token_level_id = 2 and token_recording_id = 1

select token_symbol as syllables, label_name as annotation
from tokens 
join labels on label_id = token_label_id
where token_level_id = 3 and token_recording_id = 1

select token_symbol as words, label_name as annotation
from tokens 
join labels on label_id = token_label_id
where token_level_id = 5 and token_recording_id = 1

select token_symbol as phrases, label_name as annotation
from tokens 
join labels on label_id = token_label_id
where token_label_id = 11 or token_label_id = 12 and token_recording_id = 1

select token_symbol as words, label_name as annotation
from tokens 
join labels on label_id = token_label_id
where token_label_id = 13 and token_recording_id = 1


--Display all the rules in the system 
--I created many views for the rules to be displayed. 
--With the views, only the query with the UNION clauses in the end is needed to display the rules.
drop view if exists v_mother_nodes
go
create view v_mother_nodes as 
select rule_id, label_name as [mother node]
from labels
join rules on mother_label_id = label_id
GO
select * from v_mother_nodes
go
drop view if exists v_first_daughter_nodes
go
create view v_first_daughter_nodes as 
select rule_id, label_name as [first daughter node]
from labels
join rules on daughter1_label_id = label_id
GO
select * from v_first_daughter_nodes
go
drop view if exists v_second_daughter_nodes
go
create view v_second_daughter_nodes as 
select rule_id, label_name as [second daughter node]
from labels
join rules on daughter2_label_id = label_id
GO
select * from v_second_daughter_nodes
go
drop view if exists v_third_daughter_nodes
go
create view v_third_daughter_nodes as 
select rule_id, label_name as [third daughter node]
from labels
join rules on daughter3_label_id = label_id
GO
select * from v_third_daughter_nodes
GO

drop view if exists v_three_daughter_nodes
go
create view v_three_daughter_nodes as 
select m.rule_id, m.[mother node], f.[first daughter node], s.[second daughter node], t.[third daughter node]
from v_mother_nodes as m
join v_first_daughter_nodes as f on m.rule_id = f.rule_id
join v_second_daughter_nodes as s on m.rule_id = s.rule_id
join v_third_daughter_nodes as t on m.rule_id = t.rule_id
go
select * from v_three_daughter_nodes
go
drop view if exists v_two_daughter_nodes
go
create view v_two_daughter_nodes as
select m.rule_id, m.[mother node], f.[first daughter node], s.[second daughter node], ' ' as [third daughter node]
from v_mother_nodes as m
join v_first_daughter_nodes as f on m.rule_id = f.rule_id
join v_second_daughter_nodes as s on m.rule_id = s.rule_id
where m.rule_id != 7
go
select * from v_two_daughter_nodes
GO
drop view if exists v_one_daughter_node
go
create view v_one_daughter_node as
select m.rule_id, m.[mother node], f.[first daughter node], ' ' as [second daughter node], ' ' as [third daughter node]
from v_mother_nodes as m
join v_first_daughter_nodes as f on m.rule_id = f.rule_id
where m.rule_id != 5 and m.rule_id != 7 and m.rule_id != 12 and m.rule_id != 13
GO
select * from v_one_daughter_node
go

drop view if exists v_no_daughter_node
go
create view v_no_daughter_node as
select m.rule_id, m.[mother node], ' ' as [first daughter node], ' ' as [second daughter node], ' ' as [third daughter node]
from v_mother_nodes as m
where m.rule_id = 2
GO
select * from v_no_daughter_node

SELECT rule_id, [mother node], [first daughter node], [second daughter node], [third daughter node] FROM v_three_daughter_nodes
UNION
SELECT rule_id, [mother node], [first daughter node], [second daughter node], [third daughter node] FROM v_two_daughter_nodes
UNION
select rule_id, [mother node], [first daughter node], [second daughter node], [third daughter node] from v_one_daughter_node
UNION
select rule_id, [mother node], [first daughter node], [second daughter node], [third daughter node] from v_no_daughter_node
order by rule_id

