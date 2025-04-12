// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 < 0.9.0;

import "./libraries/ArrayUtils.sol";

contract Blogging {
    using ArrayUtils for string[];
    using ArrayUtils for address[];
    using ArrayUtils for Post[];
    using ArrayUtils for Comment[];

    event NewPost(string cid, address author, uint256 timestamp);
    event NewComment(string postCid, string cid, 
        address commenter, uint256 timestamp);
    event NewLike(address user, string postCid);
    event ReceiveTip(string postCid, address author);
    event DeletePost(string cid, address author);
    event DeleteComment(string cid, address commenter);
    event Logging(int256 id, string cid);

    struct Post {
        string cid;
        address author;
        uint256 timestamp;
    }

    struct Comment {
        string cid;
        string postCid;
        address commenter;
        uint256 timestamp;
    }

    constructor () {
    }

    address[] public authors;
    mapping (address => Post[]) public authorPosts;
    mapping (string => Comment[]) public postComments;
    mapping (address => Comment[]) public userComments;
    mapping (string => address[]) public postLikes;
    mapping (address => string[]) public userLikes;

    modifier postExists(address author, string memory postCid) {
        int256 postId = authorPosts[author].findIndex(postCid);
        require(postId > -1, "Post does not exist");
        _;
    }

    modifier commentExists(string memory postCid, string memory commentCid) {
        int256 commentId = postComments[postCid].findIndex(commentCid);
        require(commentId > -1, "Comment does not exist");
        _;
    }

    modifier onlyPostOwner(address author) {
        require(msg.sender == author, "Only post owner can do this action");
        _;
    }

    modifier onlyCommentOwnerOrPostOwner(address commenter, address author) {
        require(msg.sender == commenter || msg.sender == author, "Only comment or post owner can do this action");
        _;
    }

    modifier notLiked(string memory postCid) {
        int256 postId = userLikes[msg.sender].findIndex(postCid);
        require(postId > -1, "User hasn't liked post");
        _;
    }

    function getCommentsCopy(string memory cid) private view returns (Comment[] memory) {
        Comment[] storage original = postComments[cid];
        Comment[] memory copy = new Comment[](original.length);
        
        for (uint i = 0; i < original.length; i++) {
            copy[i] = original[i];
        }
    
        return copy;
    }

    function getAdressesCopy(string memory cid) private view returns (address[] memory) {
        address[] storage original = postLikes[cid];
        address[] memory copy = new address[](original.length);
        
        for (uint i = 0; i < original.length; i++) {
            copy[i] = original[i];
        }
    
        return copy;
    }

    function min(uint256 i, uint256 j) private pure returns (uint256) {
        if (i < j) return i;
        else return j;
    }
    
    function max(uint256 i, uint256 j) private pure returns (uint256) {
        if (j > i) return i;
        else return j;
    }

    function addPost(string memory cid, uint256 timestamp) public {
        address author = msg.sender;
        Post[] storage currAuthorPosts = authorPosts[author];
        if (currAuthorPosts.length == 0) {
            authors.push(author);
        }
        currAuthorPosts.push(Post({cid: cid, author: author, 
            timestamp: timestamp}));
        authorPosts[author] = currAuthorPosts;
        emit NewPost(cid, author, timestamp);
    }

    function deletePost(string memory cid, address author) 
        postExists(author, cid) onlyPostOwner(author) public {
        address[] memory copiedPostLikes = getAdressesCopy(cid);
        for (uint i = 0; i < copiedPostLikes.length; i++) {
            address user = copiedPostLikes[i];
            postLikes[cid].removeElementByIndex(
                postLikes[cid].findIndex(user));
            userLikes[user].removeElementByIndex(
                userLikes[user].findIndex(cid));
        }
        Comment[] memory copiedPostComments = getCommentsCopy(cid);
        for (uint i = 0; i < copiedPostComments.length; i++) {
            Comment memory comment = copiedPostComments[i];
            deleteComment(cid, comment.cid, author, comment.commenter);
        }
        int256 postId = authorPosts[author].findIndex(cid);
        authorPosts[author].removeElementByIndex(postId);
        if (authorPosts[author].length == 0) {
            authors.removeElementByIndex(authors.findIndex(author));
        }
        emit DeletePost(cid, author);
    }

    function tipAuthor(string memory postCid, address author) 
        postExists(author, postCid) public payable {
        payable(author).transfer(msg.value);
        emit ReceiveTip(postCid, author);
    }

    function addComment(string memory postCid, string memory cid, 
        address author, uint256 timestamp) postExists(author, postCid) public {
        address commenter = msg.sender;
        Comment memory newComment = Comment({ cid: cid, 
            commenter: commenter, postCid: postCid, timestamp: timestamp });
        postComments[postCid].push(newComment);
        userComments[commenter].push(newComment);
        emit NewComment(postCid, cid, commenter, timestamp);
    }

    function deleteComment(string memory postCid, string memory cid, 
        address author, address commenter) postExists(author, postCid) 
        commentExists(postCid, cid) onlyCommentOwnerOrPostOwner(commenter, author) public {
        int256 commentId = postComments[postCid].findIndex(cid);
        postComments[postCid].removeElementByIndex(commentId);
        userComments[commenter].removeElementByIndex(commentId);
        emit DeleteComment(cid, commenter);
    }

    function like(string memory postCid, address author) postExists(author, postCid) 
        public {
        address user = msg.sender;
        require(userLikes[user].findIndex(postCid) == -1, "User already liked post");
        postLikes[postCid].push(msg.sender);
        userLikes[user].push(postCid);
        emit NewLike(user, postCid);
    }

    function unlike(string memory postCid, address author) postExists(author, postCid) 
        notLiked(postCid) public {
        address user = msg.sender;
        int256 postId = userLikes[user].findIndex(postCid);
        require(postId > -1, "User hasn't liked post");
        postLikes[postCid].removeElementByIndex(
            postLikes[postCid].findIndex(user));
        userLikes[user].removeElementByIndex(
            userLikes[user].findIndex(postCid));
    }

    function getAuthors() public view returns (address[] memory) {
        return authors;
    }

    function getCommentsByPost(string memory postCid) public view returns (Comment[] memory) {
        return postComments[postCid].reverseArray();
    }

    function getCommentsNumberByPost(string memory postCid) public view returns (uint256) {
        return getCommentsByPost(postCid).length;
    }

    function getCommentsByUser(address user) public view returns (Comment[] memory) {
        return userComments[user].reverseArray();
    }

    function getLikesNumberByPost(string memory postCid) public view returns (uint256) {
        return postLikes[postCid].length;
    }

    function getLikesByUser(address user) public view returns (string[] memory) {
        return userLikes[user];
    }

    function getPostsByAuthor(address author) public view returns (Post[] memory) {
        return authorPosts[author].reverseArray();
    }

    function paginatePosts(uint256 page, uint256 limit, address author) public view returns (Post[] memory) {
        Post[] memory posts = authorPosts[author];
        uint256 start = (page - 1) * limit;
        uint256 end = min(((page - 1) * limit) + limit, posts.length);
        Post[] memory paginatedPosts = posts.sliceArray(start, end);
        return paginatedPosts.reverseArray();
    }
}