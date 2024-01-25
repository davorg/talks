create table country (
  id integer not null primary key,
  name varchar(100) unique not null
);

create table city (
  id integer not null primary key,
  name varchar(100) unique not null,
  country_id integer not null references country(id)
);

create table venue (
  id integer not null primary key,
  name varchar(100) unique not null,
  city_id integer not null references city(id)
); 

create table event_series (
  id integer not null primary key,
  name varchar(100) unique not null
);

create table event (
  id integer not null primary key,
  description varchar(300),
  start_date datetime not null,
  end_date datetime,
  venue_id integer not null references venue(id),
  event_series_id integer not null references event_series(id)
);

create table talk_type (
  id integer not null primary key,
  type char(15) unique not null
);

create table talk (
  id integer not null primary key,
  title text not null,
  video_url text,
  slide_url text
);

create table presentation (
  id integer not null primary key,
  datetime datetime,
  video_url text,
  slide_url text,
  type_id integer not null references type(id),
  talk_id integer not null references talk(id),
  event_id integer not null references event(id)
);
