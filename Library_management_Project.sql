-- CREATING A DATABASE NAMED LIBRARY 
create database library;
use library;
-- CREATING TABLE LIBIRARY_BRANCH
create table library_branch (
                            library_branch_BranchID int auto_increment primary key,
                            library_branch_BranchName varchar(200) not null,
                            library_branch_BranchAddress varchar(255) not null );
                            
-- CREATING TABLE BORROWER                         
create table borrower (
                       borrower_CardNo	int primary key,
                       borrower_BorrowerName varchar(100),	
                       borrower_BorrowerAddress	 varchar(255),
                       borrower_BorrowerPhone varchar(150) );
				
-- CREATING TABLE PUBLISHER
create table publisher(
                       publisher_PublisherName	varchar(200) primary key,
                       publisher_PublisherAddress	varchar(255),
                       publisher_PublisherPhone  varchar(150) );
                       
-- CREATING TABLE BOOK
create table book (
                   book_BookID	int primary key,
                   book_Title	varchar(200),
                   book_PublisherName varchar(200),
                   foreign key(book_PublisherName) references publisher(publisher_PublisherName)
                   on update cascade on delete cascade);
                   
-- CREATING TABLE BOOK_AUTHORS
create table book_authors(
						 book_authors_AuthorID int auto_increment primary key,
                         book_authors_BookID	int,
                         book_authors_AuthorName varchar(150),
                         foreign key (book_authors_BookID) references book(book_BookID)
                         on update cascade on delete cascade );
                         
-- CREATING TABLE BOOK_COPIES
 create table book_copies(
						book_copies_CopiesID int auto_increment primary key,
                        book_copies_BookID	int,
                        book_copies_BranchID	int,
                        book_copies_No_Of_Copies int,
                  foreign key(book_copies_BookID) references book (book_BookID)
                  on update cascade on delete cascade,
                  foreign key(book_copies_BranchID) references library_branch (library_branch_BranchID)
                  on update cascade on delete cascade );
                  
-- CREATING TABLE BOOK_LOANS          
create table book_loans( 
                        book_loans_LoansID int auto_increment primary key,
                        book_loans_BookID	int,
                        book_loans_BranchID	int,
                        book_loans_CardNo	int,
                        book_loans_DateOut	varchar(100),
                        book_loans_DueDate  varchar(100),
                       foreign key(book_loans_BookID) references book (book_BookID)
                       on update cascade on delete cascade,
                       foreign key (book_loans_BranchID) references library_branch(library_branch_BranchID)
                       on update cascade on delete cascade,
                       foreign key (book_loans_CardNo) references borrower (borrower_CardNo)
                       on update cascade on delete cascade);

select * from book;
select * from book_authors;
select * from book_copies;
select * from book_loans;
select * from borrower;
select * from library_branch;
select * from publisher;

describe book;
show tables;

-- QUESTION - 1
-- How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"
select sum(book_copies_No_Of_Copies) as count_of_copies from book_copies 
inner join book
on book.book_BookID = book_copies .book_copies_BookID
inner join library_branch
on book_copies.book_copies_BranchID = library_branch.library_branch_BranchID
where library_branch_BranchName = "Sharpstown" and book_Title = "The Lost Tribe";

/** THE NUMBER OF COPIES ARE : 5 **/

-- QUESTION - 2
-- How many copies of the book titled "The Lost Tribe" are owned by each library branch?

select library_branch_BranchName, sum(book_copies_No_Of_Copies) as count_of_copies from book_copies 
inner join book
on book.book_BookID = book_copies .book_copies_BookID
inner join library_branch
on book_copies.book_copies_BranchID = library_branch.library_branch_BranchID
where book_Title = "The Lost Tribe"
group by library_branch_BranchName;

/** THE COPIES ARE 5 FOR BOOK NAMED THE LOST TRIBE FOR EACH LIBRARY **/

-- QUESTION - 3
-- Retrieve the names of all borrowers who do not have any books checked out
-- USING JOINS
select borrower_BorrowerName from borrower
left join book_loans
on borrower. borrower_CardNo = book_loans.book_loans_CardNo
where book_loans_CardNo is null;

-- Using SubQuery
select borrower_BorrowerName from borrower where borrower_CardNo not in(select book_loans_cardno from book_loans);

/** THE NAMES OF THE BORROWER WHO DO NOT HAVE ANY BOOK CHECKED OUT IS JANE SMITH **/

-- QUESTION -4
-- For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address

select * from book_loans;
select * from library_branch;
select * from borrower;
select * from book;

select b.book_title, br.borrower_BorrowerName ,br.borrower_BorrowerAddress from book b
inner join book_loans bl
on b.book_BookID = bl.book_loans_BookID
inner join borrower  br 
on bl.book_loans_CardNo = br.borrower_CardNo
inner join library_branch lb
on bl.book_loans_BranchID = lb.library_branch_BranchID
where lb.library_branch_BranchName = "Sharpstown" and book_loans_DueDate = "2/3/18";

-- QUESTION - 5
-- For each library branch, retrieve the branch name and the total number of books loaned out from that branch.

select library_branch_BranchName,count(book_loans_BookID) as total_books_loaned from library_branch
inner join book_loans
on library_branch_BranchID = book_loans_BranchID
group by library_branch_BranchName;

-- QUESTION - 6
-- Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out

select * from book_loans;

select  borrower_borrowerName, borrower_BorrowerAddress,count(book_loans_BookID) as check_out_books from borrower
inner join book_loans
on borrower_CardNo = book_loans_CardNo
group by book_loans_CardNo,borrower_BorrowerName, borrower_BorrowerAddress
having check_out_books >5
order by check_out_books desc;

-- QUESTION - 7
-- For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
select * from book;
select * from book_authors;
select * from book_copies;
select * from library_branch;

select book_Title,sum(book_copies_No_Of_Copies) as no_of_copies_owned  from book 
inner join book_authors 
on book.book_BookID = book_authors.book_authors_BookID
left join book_copies 
on book.book_BookID = book_copies.book_copies_BookID
left join library_branch
on book_copies_BranchID = library_branch_BranchID
where book_authors_AuthorName = "Stephen King" and library_branch_BranchName = "Central"
group by book_Title;

