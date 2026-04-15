--
-- PostgreSQL database dump
--

\restrict e7kCVNIRFr7HjWc64hQeV1BEJ5jERYVWPV3SwBr0yGNIURdLF3brhu8XbsLwlDh

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: academic_term; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.academic_term (
    term_id integer NOT NULL,
    program_id integer NOT NULL,
    year integer NOT NULL,
    semester_number integer NOT NULL,
    start_date date,
    end_date date,
    CONSTRAINT academic_term_semester_number_check CHECK ((semester_number > 0)),
    CONSTRAINT academic_term_year_check CHECK ((year >= 2000))
);


ALTER TABLE public.academic_term OWNER TO postgres;

--
-- Name: academic_term_term_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.academic_term_term_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.academic_term_term_id_seq OWNER TO postgres;

--
-- Name: academic_term_term_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.academic_term_term_id_seq OWNED BY public.academic_term.term_id;


--
-- Name: attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance (
    attendance_id integer NOT NULL,
    enrollment_id integer NOT NULL,
    session_id integer NOT NULL,
    status character varying(10) NOT NULL,
    CONSTRAINT attendance_status_check CHECK (((status)::text = ANY ((ARRAY['PRESENT'::character varying, 'ABSENT'::character varying])::text[])))
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- Name: attendance_attendance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.attendance_attendance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.attendance_attendance_id_seq OWNER TO postgres;

--
-- Name: attendance_attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.attendance_attendance_id_seq OWNED BY public.attendance.attendance_id;


--
-- Name: campus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.campus (
    campus_id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.campus OWNER TO postgres;

--
-- Name: campus_campus_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.campus_campus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.campus_campus_id_seq OWNER TO postgres;

--
-- Name: campus_campus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.campus_campus_id_seq OWNED BY public.campus.campus_id;


--
-- Name: course; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course (
    course_id integer NOT NULL,
    course_code character varying(20) NOT NULL,
    name character varying(100) NOT NULL,
    dept_id integer NOT NULL,
    credits integer,
    CONSTRAINT course_credits_check CHECK ((credits >= 0))
);


ALTER TABLE public.course OWNER TO postgres;

--
-- Name: course_course_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.course_course_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.course_course_id_seq OWNER TO postgres;

--
-- Name: course_course_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.course_course_id_seq OWNED BY public.course.course_id;


--
-- Name: course_offering; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course_offering (
    offering_id integer NOT NULL,
    course_id integer NOT NULL,
    term_id integer NOT NULL,
    faculty_name character varying(100),
    is_elective boolean DEFAULT false
);


ALTER TABLE public.course_offering OWNER TO postgres;

--
-- Name: course_offering_offering_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.course_offering_offering_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.course_offering_offering_id_seq OWNER TO postgres;

--
-- Name: course_offering_offering_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.course_offering_offering_id_seq OWNED BY public.course_offering.offering_id;


--
-- Name: department; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.department (
    dept_id integer NOT NULL,
    name character varying(100) NOT NULL,
    school_id integer NOT NULL
);


ALTER TABLE public.department OWNER TO postgres;

--
-- Name: department_dept_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.department_dept_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.department_dept_id_seq OWNER TO postgres;

--
-- Name: department_dept_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.department_dept_id_seq OWNED BY public.department.dept_id;


--
-- Name: elective_selection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.elective_selection (
    id integer NOT NULL,
    register_no character varying(20) NOT NULL,
    offering_id integer NOT NULL
);


ALTER TABLE public.elective_selection OWNER TO postgres;

--
-- Name: elective_selection_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.elective_selection_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.elective_selection_id_seq OWNER TO postgres;

--
-- Name: elective_selection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.elective_selection_id_seq OWNED BY public.elective_selection.id;


--
-- Name: enrollment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enrollment (
    enrollment_id integer NOT NULL,
    register_no character varying(20) NOT NULL,
    offering_id integer NOT NULL
);


ALTER TABLE public.enrollment OWNER TO postgres;

--
-- Name: enrollment_enrollment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.enrollment_enrollment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.enrollment_enrollment_id_seq OWNER TO postgres;

--
-- Name: enrollment_enrollment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.enrollment_enrollment_id_seq OWNED BY public.enrollment.enrollment_id;


--
-- Name: hostel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hostel (
    hostel_id integer NOT NULL,
    name character varying(100) NOT NULL,
    campus_id integer NOT NULL,
    type character varying(10),
    total_rooms integer,
    food boolean DEFAULT false,
    laundry boolean DEFAULT false,
    CONSTRAINT hostel_total_rooms_check CHECK ((total_rooms >= 0)),
    CONSTRAINT hostel_type_check CHECK (((type)::text = ANY ((ARRAY['BOYS'::character varying, 'GIRLS'::character varying])::text[])))
);


ALTER TABLE public.hostel OWNER TO postgres;

--
-- Name: hostel_allocation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hostel_allocation (
    allocation_id integer NOT NULL,
    register_no character varying(20) NOT NULL,
    hostel_id integer NOT NULL,
    room_number character varying(10),
    start_date date NOT NULL,
    end_date date,
    dues numeric(10,2) DEFAULT 0.00
);


ALTER TABLE public.hostel_allocation OWNER TO postgres;

--
-- Name: hostel_allocation_allocation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hostel_allocation_allocation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hostel_allocation_allocation_id_seq OWNER TO postgres;

--
-- Name: hostel_allocation_allocation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hostel_allocation_allocation_id_seq OWNED BY public.hostel_allocation.allocation_id;


--
-- Name: hostel_hostel_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hostel_hostel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hostel_hostel_id_seq OWNER TO postgres;

--
-- Name: hostel_hostel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hostel_hostel_id_seq OWNED BY public.hostel.hostel_id;


--
-- Name: hostel_leave; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hostel_leave (
    leave_id integer NOT NULL,
    register_no character varying(20) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    reason text,
    status character varying(20) DEFAULT 'pending'::character varying,
    CONSTRAINT hostel_leave_status_check CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('approved'::character varying)::text, ('rejected'::character varying)::text])))
);


ALTER TABLE public.hostel_leave OWNER TO postgres;

--
-- Name: hostel_leave_leave_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hostel_leave_leave_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hostel_leave_leave_id_seq OWNER TO postgres;

--
-- Name: hostel_leave_leave_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hostel_leave_leave_id_seq OWNED BY public.hostel_leave.leave_id;


--
-- Name: program; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.program (
    program_id integer NOT NULL,
    name character varying(50) NOT NULL,
    dept_id integer NOT NULL
);


ALTER TABLE public.program OWNER TO postgres;

--
-- Name: program_program_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.program_program_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.program_program_id_seq OWNER TO postgres;

--
-- Name: program_program_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.program_program_id_seq OWNED BY public.program.program_id;


--
-- Name: school; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.school (
    school_id integer NOT NULL,
    name character varying(100) NOT NULL,
    campus_id integer NOT NULL
);


ALTER TABLE public.school OWNER TO postgres;

--
-- Name: school_school_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.school_school_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.school_school_id_seq OWNER TO postgres;

--
-- Name: school_school_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.school_school_id_seq OWNED BY public.school.school_id;


--
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    session_id integer NOT NULL,
    offering_id integer NOT NULL,
    session_date date NOT NULL,
    topic text
);


ALTER TABLE public.session OWNER TO postgres;

--
-- Name: session_session_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.session_session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.session_session_id_seq OWNER TO postgres;

--
-- Name: session_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.session_session_id_seq OWNED BY public.session.session_id;


--
-- Name: student; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student (
    register_no character varying(20) NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    program_id integer NOT NULL,
    joined_date date NOT NULL,
    password_hash text NOT NULL,
    email character varying(150) NOT NULL,
    class character varying(20),
    current_term_id integer
);


ALTER TABLE public.student OWNER TO postgres;

--
-- Name: term_course_map; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.term_course_map (
    id integer NOT NULL,
    term_id integer NOT NULL,
    course_id integer NOT NULL,
    is_elective boolean DEFAULT false
);


ALTER TABLE public.term_course_map OWNER TO postgres;

--
-- Name: term_course_map_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.term_course_map_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.term_course_map_id_seq OWNER TO postgres;

--
-- Name: term_course_map_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.term_course_map_id_seq OWNED BY public.term_course_map.id;


--
-- Name: tool_registry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tool_registry (
    id integer NOT NULL,
    name character varying(100),
    module character varying(200),
    function_name character varying(100),
    description text,
    parameters jsonb,
    active boolean DEFAULT true
);


ALTER TABLE public.tool_registry OWNER TO postgres;

--
-- Name: tool_registry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tool_registry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tool_registry_id_seq OWNER TO postgres;

--
-- Name: tool_registry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tool_registry_id_seq OWNED BY public.tool_registry.id;


--
-- Name: academic_term term_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_term ALTER COLUMN term_id SET DEFAULT nextval('public.academic_term_term_id_seq'::regclass);


--
-- Name: attendance attendance_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance ALTER COLUMN attendance_id SET DEFAULT nextval('public.attendance_attendance_id_seq'::regclass);


--
-- Name: campus campus_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campus ALTER COLUMN campus_id SET DEFAULT nextval('public.campus_campus_id_seq'::regclass);


--
-- Name: course course_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course ALTER COLUMN course_id SET DEFAULT nextval('public.course_course_id_seq'::regclass);


--
-- Name: course_offering offering_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_offering ALTER COLUMN offering_id SET DEFAULT nextval('public.course_offering_offering_id_seq'::regclass);


--
-- Name: department dept_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department ALTER COLUMN dept_id SET DEFAULT nextval('public.department_dept_id_seq'::regclass);


--
-- Name: elective_selection id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_selection ALTER COLUMN id SET DEFAULT nextval('public.elective_selection_id_seq'::regclass);


--
-- Name: enrollment enrollment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment ALTER COLUMN enrollment_id SET DEFAULT nextval('public.enrollment_enrollment_id_seq'::regclass);


--
-- Name: hostel hostel_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hostel ALTER COLUMN hostel_id SET DEFAULT nextval('public.hostel_hostel_id_seq'::regclass);


--
-- Name: hostel_allocation allocation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hostel_allocation ALTER COLUMN allocation_id SET DEFAULT nextval('public.hostel_allocation_allocation_id_seq'::regclass);


--
-- Name: hostel_leave leave_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hostel_leave ALTER COLUMN leave_id SET DEFAULT nextval('public.hostel_leave_leave_id_seq'::regclass);


--
-- Name: program program_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.program ALTER COLUMN program_id SET DEFAULT nextval('public.program_program_id_seq'::regclass);


--
-- Name: school school_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school ALTER COLUMN school_id SET DEFAULT nextval('public.school_school_id_seq'::regclass);


--
-- Name: session session_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session ALTER COLUMN session_id SET DEFAULT nextval('public.session_session_id_seq'::regclass);


--
-- Name: term_course_map id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.term_course_map ALTER COLUMN id SET DEFAULT nextval('public.term_course_map_id_seq'::regclass);


--
-- Name: tool_registry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_registry ALTER COLUMN id SET DEFAULT nextval('public.tool_registry_id_seq'::regclass);


--
-- Name: academic_term academic_term_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_term
    ADD CONSTRAINT academic_term_pkey PRIMARY KEY (term_id);


--
-- Name: academic_term academic_term_program_id_year_semester_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_term
    ADD CONSTRAINT academic_term_program_id_year_semester_number_key UNIQUE (program_id, year, semester_number);


--
-- Name: attendance attendance_enrollment_id_session_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_enrollment_id_session_id_key UNIQUE (enrollment_id, session_id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (attendance_id);


--
-- Name: campus campus_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campus
    ADD CONSTRAINT campus_name_key UNIQUE (name);


--
-- Name: campus campus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.campus
    ADD CONSTRAINT campus_pkey PRIMARY KEY (campus_id);


--
-- Name: course course_course_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_course_code_key UNIQUE (course_code);


--
-- Name: course_offering course_offering_course_id_term_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_offering
    ADD CONSTRAINT course_offering_course_id_term_id_key UNIQUE (course_id, term_id);


--
-- Name: course_offering course_offering_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_offering
    ADD CONSTRAINT course_offering_pkey PRIMARY KEY (offering_id);


--
-- Name: course course_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (course_id);


--
-- Name: department department_name_school_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_name_school_id_key UNIQUE (name, school_id);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (dept_id);


--
-- Name: elective_selection elective_selection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_selection
    ADD CONSTRAINT elective_selection_pkey PRIMARY KEY (id);


--
-- Name: elective_selection elective_selection_register_no_offering_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_selection
    ADD CONSTRAINT elective_selection_register_no_offering_id_key UNIQUE (register_no, offering_id);


--
-- Name: enrollment enrollment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_pkey PRIMARY KEY (enrollment_id);


--
-- Name: enrollment enrollment_register_no_offering_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_register_no_offering_id_key UNIQUE (register_no, offering_id);


--
-- Name: hostel_allocation hostel_allocation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hostel_allocation
    ADD CONSTRAINT hostel_allocation_pkey PRIMARY KEY (allocation_id);


--
-- Name: hostel_leave hostel_leave_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hostel_leave
    ADD CONSTRAINT hostel_leave_pkey PRIMARY KEY (leave_id);


--
-- Name: hostel hostel_name_campus_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hostel
    ADD CONSTRAINT hostel_name_campus_id_key UNIQUE (name, campus_id);


--
-- Name: hostel hostel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hostel
    ADD CONSTRAINT hostel_pkey PRIMARY KEY (hostel_id);


--
-- Name: program program_name_dept_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT program_name_dept_id_key UNIQUE (name, dept_id);


--
-- Name: program program_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT program_pkey PRIMARY KEY (program_id);


--
-- Name: school school_name_campus_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school
    ADD CONSTRAINT school_name_campus_id_key UNIQUE (name, campus_id);


--
-- Name: school school_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school
    ADD CONSTRAINT school_pkey PRIMARY KEY (school_id);


--
-- Name: session session_offering_id_session_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_offering_id_session_date_key UNIQUE (offering_id, session_date);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (session_id);


--
-- Name: student student_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_email_key UNIQUE (email);


--
-- Name: student student_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (register_no);


--
-- Name: term_course_map term_course_map_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.term_course_map
    ADD CONSTRAINT term_course_map_pkey PRIMARY KEY (id);


--
-- Name: term_course_map term_course_map_term_id_course_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.term_course_map
    ADD CONSTRAINT term_course_map_term_id_course_id_key UNIQUE (term_id, course_id);


--
-- Name: tool_registry tool_registry_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_registry
    ADD CONSTRAINT tool_registry_name_key UNIQUE (name);


--
-- Name: tool_registry tool_registry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tool_registry
    ADD CONSTRAINT tool_registry_pkey PRIMARY KEY (id);


--
-- Name: academic_term academic_term_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.academic_term
    ADD CONSTRAINT academic_term_program_id_fkey FOREIGN KEY (program_id) REFERENCES public.program(program_id);


--
-- Name: attendance attendance_enrollment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_enrollment_id_fkey FOREIGN KEY (enrollment_id) REFERENCES public.enrollment(enrollment_id) ON DELETE CASCADE;


--
-- Name: attendance attendance_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.session(session_id) ON DELETE CASCADE;


--
-- Name: course course_dept_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_dept_id_fkey FOREIGN KEY (dept_id) REFERENCES public.department(dept_id);


--
-- Name: course_offering course_offering_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_offering
    ADD CONSTRAINT course_offering_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.course(course_id) ON DELETE CASCADE;


--
-- Name: course_offering course_offering_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course_offering
    ADD CONSTRAINT course_offering_term_id_fkey FOREIGN KEY (term_id) REFERENCES public.academic_term(term_id) ON DELETE CASCADE;


--
-- Name: department department_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department
    ADD CONSTRAINT department_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.school(school_id) ON DELETE CASCADE;


--
-- Name: elective_selection elective_selection_offering_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_selection
    ADD CONSTRAINT elective_selection_offering_id_fkey FOREIGN KEY (offering_id) REFERENCES public.course_offering(offering_id) ON DELETE CASCADE;


--
-- Name: elective_selection elective_selection_register_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.elective_selection
    ADD CONSTRAINT elective_selection_register_no_fkey FOREIGN KEY (register_no) REFERENCES public.student(register_no) ON DELETE CASCADE;


--
-- Name: enrollment enrollment_offering_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_offering_id_fkey FOREIGN KEY (offering_id) REFERENCES public.course_offering(offering_id) ON DELETE CASCADE;


--
-- Name: enrollment enrollment_register_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_register_no_fkey FOREIGN KEY (register_no) REFERENCES public.student(register_no) ON DELETE CASCADE;


--
-- Name: hostel_allocation hostel_allocation_hostel_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hostel_allocation
    ADD CONSTRAINT hostel_allocation_hostel_id_fkey FOREIGN KEY (hostel_id) REFERENCES public.hostel(hostel_id) ON DELETE CASCADE;


--
-- Name: hostel_allocation hostel_allocation_register_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hostel_allocation
    ADD CONSTRAINT hostel_allocation_register_no_fkey FOREIGN KEY (register_no) REFERENCES public.student(register_no) ON DELETE CASCADE;


--
-- Name: hostel hostel_campus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hostel
    ADD CONSTRAINT hostel_campus_id_fkey FOREIGN KEY (campus_id) REFERENCES public.campus(campus_id);


--
-- Name: hostel_leave hostel_leave_register_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hostel_leave
    ADD CONSTRAINT hostel_leave_register_no_fkey FOREIGN KEY (register_no) REFERENCES public.student(register_no) ON DELETE CASCADE;


--
-- Name: program program_dept_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.program
    ADD CONSTRAINT program_dept_id_fkey FOREIGN KEY (dept_id) REFERENCES public.department(dept_id) ON DELETE CASCADE;


--
-- Name: school school_campus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.school
    ADD CONSTRAINT school_campus_id_fkey FOREIGN KEY (campus_id) REFERENCES public.campus(campus_id) ON DELETE CASCADE;


--
-- Name: session session_offering_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_offering_id_fkey FOREIGN KEY (offering_id) REFERENCES public.course_offering(offering_id) ON DELETE CASCADE;


--
-- Name: student student_current_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_current_term_id_fkey FOREIGN KEY (current_term_id) REFERENCES public.academic_term(term_id);


--
-- Name: student student_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_program_id_fkey FOREIGN KEY (program_id) REFERENCES public.program(program_id);


--
-- Name: term_course_map term_course_map_course_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.term_course_map
    ADD CONSTRAINT term_course_map_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.course(course_id) ON DELETE CASCADE;


--
-- Name: term_course_map term_course_map_term_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.term_course_map
    ADD CONSTRAINT term_course_map_term_id_fkey FOREIGN KEY (term_id) REFERENCES public.academic_term(term_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict e7kCVNIRFr7HjWc64hQeV1BEJ5jERYVWPV3SwBr0yGNIURdLF3brhu8XbsLwlDh

