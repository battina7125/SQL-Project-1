select* from project.dbo.data1;
select* from project.dbo.data2;
--number of rows into our dataset

select count(*) from project..data1
select count(*) from project..data2

-- dataset for jharkhand and bihar

select * from PROJECT..Data1 where state in ('Jharkhand', 'Bihar')

--  Population of India

select sum(Population) as Population from project..data2

-- Average growth of India

select avg(growth)*100 as avg_growth from project..data1;

-- Average growth by  State

select state, avg(growth)*100 as avg_growth from project..data1 group by state;

-- Average sex ratio by  State

select state,round( avg(Sex_Ratio),0) as avg_sex_ratio from project..data1 group by state order by avg_sex_ratio desc;

-- Average Literacy rate by  State

select state,round( avg(Literacy),0) as avg_literacy_ratio from project..data1 group by state order by avg_literacy_ratio desc;

-- Average Literacy rate by  State > 90

select state,round( avg(Literacy),0) as avg_literacy_ratio from project..data1 
group by state having round( avg(Literacy),0) > 90 order by avg_literacy_ratio desc;

-- Top 3 states showing highest average growth ratio

select top 3 state,avg(growth)*100 as avg_growth from project..data1 group by state order by avg_growth desc;
--or can also use this query to get the result but this query is not working
select state,avg(growth)*100 as avg_growth from project..data1 group by state order by avg_growth desc limit 3;

-- Bottom 3 states showing lowest average sex ratio

select top 3 state, round( avg(sex_Ratio),0) as avg_sex_ratio from project..data1 group by state order by avg_sex_ratio asc;

-- top 3 states in literacy by state

drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstates float

  )

insert into #topstates
select state,round(avg(literacy),0) avg_literacy_ratio from project..data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #topstates order by #topstates.topstates desc;

--  bottom 3 states in literacy by state


drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstate float

  )

insert into #bottomstates
select state,round(avg(literacy),0) avg_literacy_ratio from project..data1 
group by state order by avg_literacy_ratio desc;

select top 3 * from #bottomstates order by #bottomstates.bottomstate asc;


--  Union operator

select* from(
select top 3 * from #topstates order by #topstates.topstates desc) a

union

select* from(
select top 3 * from #bottomstates order by #bottomstates.bottomstate asc) b;

-- States starting with letter a

select distinct state from project..data1 where lower(state) like 'a%' 

-- States starting with letter a or b

select distinct state from project..data1 where lower(state) like 'a%'  or lower(state) like'b%'

-- States starting with letter a and ending with letter m

select distinct state from project..data1 where lower(state) like 'a%'  and  lower(state) like'%m'



-- Joining both tables

select a.district,a.state,a.sex_ratio, b.population from project..data1 as a inner join project..data2 as b on a.district=b.district

/*females/males=sex_ration..........1
females+males=population..........2
females=population-males..........3
(population-males) = (sex_ratio)*males
population= (sex_ratio)*males+males  =males(sex_ratio+1)
males=populatio/(sex_ratio+1).....males
females=population-population/(sex_ratio+1)....females 
females =population(1-1/(sex_ratio+1))=(population*(sex_ratio+1)-1)/(sex_ratio+1)=(population*(sex_ratio))/(sex_ratio+1) */


-- state wise population of males and females
select c.district,c.state,round(c.population/(sex_ratio+1),0) as males,round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) as females from
(select a.district,a.state,a.sex_ratio, b.population from project..data1 as a
inner join project..data2 as b on a.district=b.district) as c

-- state wise population of males and females

select d.state,sum(d.males) as total_males,sum(d.females) as total_females from
(select c.district,c.state,round(c.population/(sex_ratio+1),0) as males,round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) as females from
(select a.district,a.state,a.sex_ratio/1000 as sex_ratio, b.population from project..data1 as a
inner join project..data2 as b on a.district=b.district) as c) as d
group by d.state;




-- total literacy rate

select a.district,a.state,a.literacy as literacy_ratio, b.population from project..data1 as a
inner join project..data2 as b on a.district=b.district


-- total literacy rate

/* total literate people/population=literacy_ration----1
total literate people= literacrcy_ratio*population
total illiterate people=(1-literacy_ratio)*population
females+males= population.................................2
females= population-males.................................3
(population-males)=(sex_ratio)males
population=males(sex_ratio+1)
males=population/(sex_ratio+1)............................males
females= population-population/(sex_ratio+1)..............females
=population

*/

-- total literate and illiterate People by district

select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)*d.population,0) as illiterate_people from 
(select a.district,a.state,a.literacy/100 as literacy_ratio, b.population from project..data1 as a
inner join project..data2 as b on a.district=b.district) d

-- total literate and illiterate People by state wise using groupby function

select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_illiterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people,
round((1-d.literacy_ratio)*d.population,0) as illiterate_people from 
(select a.district,a.state,a.literacy/100 as literacy_ratio, b.population from project..data1 as a
inner join project..data2 as b on a.district=b.district) d)c 
group by c.state


-- To get Population  and Growth district wise 

select a.district,a.state,a.growth as growth, b.population from project..data1 as a
inner join project..data2 as b on a.district=b.district


/*Population
previous_census+growth*previous_census=population
previous_census=population/(1+growth)
*/
--To get previous census >>previous_census=population/(1+growth)


--Population in previous_census and current_census


select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,
d.population current_census_population from 
(select a.district,a.state,a.growth as growth, b.population from project..data1 as a
inner join project..data2 as b on a.district=b.district)d

--Total population growth of the State  by group by


select e.state,sum(e.previous_census_population)previous_census_population,sum (e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,
d.population current_census_population from 
(select a.district,a.state,a.growth as growth, b.population from project..data1 as a
inner join project..data2 as b on a.district=b.district)d)e
group by e.state

--Total population growth of the country 


select sum(m.previous_census_population)previous_census_population,sum(m.current_census_population)current_census_population from 
(select e.state,sum(e.previous_census_population)previous_census_population,sum (e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,
d.population current_census_population from 
(select a.district,a.state,a.growth as growth, b.population from project..data1 as a
inner join project..data2 as b on a.district=b.district)d)e
group by e.state)m


-- Area

select sum(area_km2)area from project..Data2

--To get Population vs Area, for this we have to join both the queries, Total population growth of the country  and Area


select '1' as keyy,n.*from
(select sum(m.previous_census_population)previous_census_population,sum(m.current_census_population)current_census_population from 
(select e.state,sum(e.previous_census_population)previous_census_population,sum (e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,
d.population current_census_population from 
(select a.district,a.state,a.growth as growth, b.population from project..data1 as a
inner join project..data2 as b on a.district=b.district)d)e
group by e.state)m)n

select '1' as keyy,z.*from
(select sum(area_km2)total_area from project..Data2)z

--after this join these two tables

select q.*,r.* from(
select '1' as keyy,n.*from
(select sum(m.previous_census_population)previous_census_population,sum(m.current_census_population)current_census_population from 
(select e.state,sum(e.previous_census_population)previous_census_population,sum (e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,
d.population current_census_population from 
(select a.district,a.state,a.growth as growth, b.population from project..data1 as a
inner join project..data2 as b on a.district=b.district)d)e
group by e.state)m)n) q inner join(

select '1' as keyy,z.*from(
select sum(area_km2)total_area from project..Data2)z) r on q.keyy=r.keyy


--To find previous_census_population_vs_area and  current_census_population_vs_area 


select (g.total_area/g.previous_census_population) as previous_census_population_vs_area, 
(g.total_area/g.current_census_population) as current_census_population_vs_area  from 
(select q.*,r.total_area from(
select '1' as keyy,n.*from
(select sum(m.previous_census_population)previous_census_population,sum(m.current_census_population)current_census_population from 
(select e.state,sum(e.previous_census_population)previous_census_population,sum (e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,
d.population current_census_population from 
(select a.district,a.state,a.growth as growth, b.population from project..data1 as a
inner join project..data2 as b on a.district=b.district)d)e
group by e.state)m)n) q inner join(

select '1' as keyy,z.*from(
select sum(area_km2)total_area from project..Data2)z) r on q.keyy=r.keyy) g

/*Using Windows function 
 Find the Top 3 districts from each state which has the highest literacy rate */

 --With first query  we will get literacy rank district wise from each state.
 select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from project..data1

 --with second query  we will get top 3 districts from each state

 select a.* from
  (select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from project..data1)a
  where a.rnk in (1,2,3) order by state

