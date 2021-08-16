// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;
import "./Ownable.sol";

contract BookLibrary is Ownable {

    uint availableBooksCount;
    
    address[] public readerAddress;
    
    mapping (address => mapping (uint => uint8)) public readerBookCopies;
    
    struct Book {
        string name;
        uint8 copies;
    }
    
    Book[] public books;
    
    modifier haveCopies(uint bookId) {
        require(books[bookId].copies > 0, "Book must have at least 1 copy");
        _;
    }
    
    modifier oneCopyOnly(uint bookId) {
        require(readerBookCopies[msg.sender][bookId] == 0, "User can't borrow more than one copy of the same book");
        _;
    }
    
    modifier checkUserCopy(uint bookId) {
        require(readerBookCopies[msg.sender][bookId] > 0, "Can't return book that you do not have");
        _;
    }

    function addBook(string memory name, uint8 copies) public onlyOwner {
        require(copies > 0, "Book must have at least 1 copy");
        books.push(Book(name, copies));
        updateAvailableBooksCount(true);
    }
    
    function listAvailableBooks() public view returns(Book[] memory availableBooks) {
        availableBooks = new Book[](availableBooksCount);
        uint count;
        for (uint i = 0; i < books.length; i++) {
            if(books[i].copies > 0) {
                availableBooks[count] = books[i];
                count++;
            }
         }
         return availableBooks;
    }
    
    function getBook(uint bookId) public haveCopies(bookId) oneCopyOnly(bookId) {
        readerAddress.push(msg.sender);
        readerBookCopies[msg.sender][bookId]++;
        books[bookId].copies--;
        updateAvailableBooksCount(false);
    }
    
    function returnBook(uint bookId) public checkUserCopy(bookId) {
        books[bookId].copies++;
        readerBookCopies[msg.sender][bookId]--;
        updateAvailableBooksCount(true);
    }
    
    function listAddress() public view returns(address[] memory) {
        return readerAddress;
    }
    
    function updateAvailableBooksCount(bool updateType) private {
        if(updateType == true) {
            availableBooksCount++;
        } else if(updateType == false) {
            availableBooksCount--;
        }
    }
}
