--
-- PostgreSQL database dump
--

\restrict FOfARMTU4NFWJZnjvs7aOaTU6kpMHf8nBjAlTjvvkg22qDcLcV2pdffPbT3XIZk

-- Dumped from database version 16.14 (Debian 16.14-1.pgdg13+1)
-- Dumped by pg_dump version 16.14 (Debian 16.14-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: export_status; Type: TYPE; Schema: public; Owner: pg-user
--

CREATE TYPE public.export_status AS ENUM (
    'pending',
    'success',
    'error'
);


ALTER TYPE public.export_status OWNER TO "pg-user";

--
-- Name: import_status; Type: TYPE; Schema: public; Owner: pg-user
--

CREATE TYPE public.import_status AS ENUM (
    'pending',
    'success',
    'error'
);


ALTER TYPE public.import_status OWNER TO "pg-user";

--
-- Name: get_id(); Type: FUNCTION; Schema: public; Owner: pg-user
--

CREATE FUNCTION public.get_id(OUT result bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
        DECLARE
            our_epoch bigint := 1514754000000;
            seq_id bigint;
            now_millis bigint;
            shard_id int := 1;
        BEGIN
            SELECT nextval('counter_seq') % 4096 INTO seq_id;

            SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp()) * 1000) INTO now_millis;
            result := (now_millis - our_epoch) << 23;
            result := result | (shard_id << 10);
            result := result | (seq_id);
        END;
        $$;


ALTER FUNCTION public.get_id(OUT result bigint) OWNER TO "pg-user";

--
-- Name: counter_seq; Type: SEQUENCE; Schema: public; Owner: pg-user
--

CREATE SEQUENCE public.counter_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.counter_seq OWNER TO "pg-user";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: export_entries; Type: TABLE; Schema: public; Owner: pg-user
--

CREATE TABLE public.export_entries (
    export_id bigint NOT NULL,
    entry_id text NOT NULL,
    mock_entry_id text NOT NULL,
    scope text NOT NULL,
    data jsonb,
    notifications jsonb
);


ALTER TABLE public.export_entries OWNER TO "pg-user";

--
-- Name: exports; Type: TABLE; Schema: public; Owner: pg-user
--

CREATE TABLE public.exports (
    export_id bigint DEFAULT public.get_id() NOT NULL,
    status public.export_status DEFAULT 'pending'::public.export_status NOT NULL,
    meta jsonb DEFAULT '{}'::jsonb,
    notifications jsonb,
    created_by text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    expired_at timestamp with time zone NOT NULL,
    tenant_id text NOT NULL
);


ALTER TABLE public.exports OWNER TO "pg-user";

--
-- Name: imports; Type: TABLE; Schema: public; Owner: pg-user
--

CREATE TABLE public.imports (
    import_id bigint DEFAULT public.get_id() NOT NULL,
    status public.import_status DEFAULT 'pending'::public.import_status NOT NULL,
    data jsonb DEFAULT '{}'::jsonb,
    meta jsonb DEFAULT '{}'::jsonb,
    notifications jsonb,
    created_by text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    expired_at timestamp with time zone NOT NULL,
    tenant_id text NOT NULL
);


ALTER TABLE public.imports OWNER TO "pg-user";

--
-- Name: migrations; Type: TABLE; Schema: public; Owner: pg-user
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    name character varying(255),
    batch integer,
    migration_time timestamp with time zone
);


ALTER TABLE public.migrations OWNER TO "pg-user";

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: pg-user
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO "pg-user";

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pg-user
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: migrations_lock; Type: TABLE; Schema: public; Owner: pg-user
--

CREATE TABLE public.migrations_lock (
    index integer NOT NULL,
    is_locked integer
);


ALTER TABLE public.migrations_lock OWNER TO "pg-user";

--
-- Name: migrations_lock_index_seq; Type: SEQUENCE; Schema: public; Owner: pg-user
--

CREATE SEQUENCE public.migrations_lock_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_lock_index_seq OWNER TO "pg-user";

--
-- Name: migrations_lock_index_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pg-user
--

ALTER SEQUENCE public.migrations_lock_index_seq OWNED BY public.migrations_lock.index;


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: pg-user
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: migrations_lock index; Type: DEFAULT; Schema: public; Owner: pg-user
--

ALTER TABLE ONLY public.migrations_lock ALTER COLUMN index SET DEFAULT nextval('public.migrations_lock_index_seq'::regclass);


--
-- Data for Name: export_entries; Type: TABLE DATA; Schema: public; Owner: pg-user
--

COPY public.export_entries (export_id, entry_id, mock_entry_id, scope, data, notifications) FROM stdin;
\.


--
-- Data for Name: exports; Type: TABLE DATA; Schema: public; Owner: pg-user
--

COPY public.exports (export_id, status, meta, notifications, created_by, created_at, updated_at, expired_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: imports; Type: TABLE DATA; Schema: public; Owner: pg-user
--

COPY public.imports (import_id, status, data, meta, notifications, created_by, created_at, updated_at, expired_at, tenant_id) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: pg-user
--

COPY public.migrations (id, name, batch, migration_time) FROM stdin;
1	20250402091721_init-meta-manager.js	1	2026-06-15 17:58:30.149+00
2	20250627114407_add-export-entries-table.js	1	2026-06-15 17:58:30.156+00
3	20250702122152_remove-export-data-column.js	1	2026-06-15 17:58:30.158+00
4	20250711081545_add-tenant-id-column.js	1	2026-06-15 17:58:30.164+00
5	20250714144135_make-tenant-id-non-null.js	1	2026-06-15 17:58:30.165+00
\.


--
-- Data for Name: migrations_lock; Type: TABLE DATA; Schema: public; Owner: pg-user
--

COPY public.migrations_lock (index, is_locked) FROM stdin;
1	0
\.


--
-- Name: counter_seq; Type: SEQUENCE SET; Schema: public; Owner: pg-user
--

SELECT pg_catalog.setval('public.counter_seq', 1, false);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pg-user
--

SELECT pg_catalog.setval('public.migrations_id_seq', 5, true);


--
-- Name: migrations_lock_index_seq; Type: SEQUENCE SET; Schema: public; Owner: pg-user
--

SELECT pg_catalog.setval('public.migrations_lock_index_seq', 1, true);


--
-- Name: export_entries export_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: pg-user
--

ALTER TABLE ONLY public.export_entries
    ADD CONSTRAINT export_entries_pkey PRIMARY KEY (export_id, entry_id);


--
-- Name: exports exports_pkey; Type: CONSTRAINT; Schema: public; Owner: pg-user
--

ALTER TABLE ONLY public.exports
    ADD CONSTRAINT exports_pkey PRIMARY KEY (export_id);


--
-- Name: imports imports_pkey; Type: CONSTRAINT; Schema: public; Owner: pg-user
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT imports_pkey PRIMARY KEY (import_id);


--
-- Name: migrations_lock migrations_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: pg-user
--

ALTER TABLE ONLY public.migrations_lock
    ADD CONSTRAINT migrations_lock_pkey PRIMARY KEY (index);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: pg-user
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: exports_export_id_tenant_id_idx; Type: INDEX; Schema: public; Owner: pg-user
--

CREATE INDEX exports_export_id_tenant_id_idx ON public.exports USING btree (export_id, tenant_id);


--
-- Name: imports_import_id_tenant_id_idx; Type: INDEX; Schema: public; Owner: pg-user
--

CREATE INDEX imports_import_id_tenant_id_idx ON public.imports USING btree (import_id, tenant_id);


--
-- Name: export_entries export_entries_export_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pg-user
--

ALTER TABLE ONLY public.export_entries
    ADD CONSTRAINT export_entries_export_id_fkey FOREIGN KEY (export_id) REFERENCES public.exports(export_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict FOfARMTU4NFWJZnjvs7aOaTU6kpMHf8nBjAlTjvvkg22qDcLcV2pdffPbT3XIZk

