// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 < 0.9.0;

contract DecentralisedBlog {
  event PostCreated(uint256 indexed postId, address indexed author, string cid, string title, uint256 indexed timestamp);
  event PostDeleted(uint256 indexed postId);
  event TagAdded(uint256 indexed postId, string tag, uint256 indexed timestamp);
  event CommentAdded(uint256 indexed commentId, uint256 indexed postId, address commenter, string cid, uint256 indexed timestamp);
  event CommentDeleted(uint256 indexed commentId);
  event PostLiked(uint256 indexed postId, address indexed liker);
  event PostUnliked(uint256 indexed postId, address indexed unliker);
  event PostBookmarked(uint256 indexed postId, address indexed bookmarker);
  event PostUnbookmarked(uint256 indexed postId, address indexed unbookmarker);
  event Followed(address indexed follower, address indexed following, uint256 indexed timestamp);
  event Unfollowed(address indexed follower, address indexed following);
  event Tipped(address indexed from, address indexed to, uint256 amount, uint256 indexed timestamp);
  event ProfileUpdated(address indexed user, string username, string bio, string imageCID, uint256 indexed timestamp);

  struct Post {
    uint256 id;
    address author;
    string cid;
    uint256 timestamp;
    uint256 likes;
    uint256 bookmarks;
    string[] imageCIDs;
    string[] tags;
    bool isDeleted;
    bool exists;
  }

  struct Comment {
    uint256 id;
    uint256 postId;
    address commenter;
    string cid;
    uint256 timestamp;
    bool isDeleted;
    bool exists;
  }

  struct UserProfile {
    string username;
    string bio;
    string imageCID;
    bool exists;
  }

  uint256 public nextPostId;
  uint256 public nextCommentId;

  mapping (uint256 => Post) public posts;
  mapping (address => uint256[]) public userPosts;

  mapping (uint256 => Comment) public comments;
  mapping (uint256 => uint256[]) public postComments;
  mapping (uint256 => mapping (address => bool)) public likes;
  mapping (uint256 => mapping (address => bool)) public bookmarks;

  mapping (address => mapping (address => bool)) public isFollowing;
  mapping (address => uint256) public followerCount;
  mapping (address => uint256) public followingCount;

  mapping (address => uint256) public reputation;

  mapping (address => UserProfile) public profiles;

  modifier onlyAuthor(uint256 postId) {
    require(posts[postId].author == msg.sender, "Not the author");
    _;
  }

  function createPost(string calldata cid, string[] calldata tags, 
    string[] calldata imageCIDs, string calldata title, uint256 timestamp) external {
    posts[nextPostId] = Post({
      id: nextPostId,
      author: msg.sender,
      cid: cid,
      timestamp: timestamp,
      likes: 0,
      bookmarks: 0,
      imageCIDs: imageCIDs,
      tags: tags,
      isDeleted: false,
      exists: true
    });
    userPosts[msg.sender].push(nextPostId);
    reputation[msg.sender] += 10;

    emit PostCreated(nextPostId, msg.sender, cid, title, timestamp);
    for (uint i = 0; i < tags.length; i++) {
      emit TagAdded(nextPostId, tags[i], timestamp);
    }
    nextPostId++;
  }

  function deletePost(uint256 postId) external onlyAuthor(postId) {
    require(posts[postId].exists, "Post doesn't exist");
    posts[postId].isDeleted = true;
    
    emit PostDeleted(postId);
  }

  function addComment(uint256 postId, string calldata cid, uint256 timestamp) external {
    require(posts[postId].exists, "Post doesn't exist");

    comments[nextCommentId] = Comment({
      id: nextCommentId, 
      postId: postId, 
      commenter: msg.sender, 
      cid: cid, 
      timestamp: timestamp,
      isDeleted: false,
      exists: true
    });
    postComments[postId].push(nextCommentId);

    reputation[msg.sender] += 3;
    emit CommentAdded(nextCommentId, postId, msg.sender, cid, timestamp);
    nextCommentId++;
  }

  function deleteComment(uint256 commentId) external {
    Comment storage comment = comments[commentId];
    require(comment.exists, "Comment doesn't exist");
    require(comment.commenter == msg.sender, "Not your comment!");
    require(!comment.isDeleted, "Already deleted");

    comment.isDeleted = true;

    emit CommentDeleted(commentId);
  }

  function like(uint256 postId) external {
    require(posts[postId].exists, "Post doesn't exist");
    require(!likes[postId][msg.sender], "Already liked");

    likes[postId][msg.sender] = true;
    posts[postId].likes++;
    reputation[msg.sender] += 1;

    emit PostLiked(postId, msg.sender);
  }

  function unlike(uint256 postId) external {
    require(likes[postId][msg.sender], "Not liked yet!");

    likes[postId][msg.sender] = false;
    posts[postId].likes--;

    emit PostUnliked(postId, msg.sender);
  }

  function bookmark(uint256 postId) external {
    require(posts[postId].exists, "Post doesn't exist");
    require(!bookmarks[postId][msg.sender], "Already bookmarked");

    bookmarks[postId][msg.sender] = true;
    posts[postId].bookmarks++;
    reputation[msg.sender] += 1;

    emit PostBookmarked(postId, msg.sender);
  }

  function unbookmark(uint256 postId) external {
    require(bookmarks[postId][msg.sender], "Not bookmarked yet!");

    bookmarks[postId][msg.sender] = false;
    posts[postId].bookmarks--;

    emit PostUnbookmarked(postId, msg.sender);
  }

  function follow(address userToFollow, uint256 timestamp) external {
    require(userToFollow != msg.sender, "Can't follow yourself!");
    require(!isFollowing[msg.sender][userToFollow], "Already following!");

    isFollowing[msg.sender][userToFollow] = true;
    followerCount[userToFollow]++;
    followingCount[msg.sender]++;
    emit Followed(msg.sender, userToFollow, timestamp);
  }

  function unfollow(address userToUnfollow) external {
    require(isFollowing[msg.sender][userToUnfollow], "Not following!");

    isFollowing[msg.sender][userToUnfollow] = false;
    followerCount[userToUnfollow]--;
    followingCount[msg.sender]--;
    emit Unfollowed(msg.sender, userToUnfollow);
  }

  function tipAuthor(uint256 postId, uint256 timestamp) external payable {
    address author = posts[postId].author;
    require(author != address(0), "Invalid author");
    require(msg.value > 0, "No tip sent");

    (bool success, ) = author.call{value: msg.value}("");
    require(success, "Transfer failed");

    emit Tipped(msg.sender, author, msg.value, timestamp);
  }

  function updateProfile(string calldata username, string calldata bio, 
    string calldata imageCID, uint256 timestamp) 
  external {
    profiles[msg.sender] = UserProfile({
      username: username,
      bio: bio,
      imageCID: imageCID,
      exists: true
    });
    emit ProfileUpdated(msg.sender, username, bio, imageCID, timestamp);
  }

  function getPostsByAuthor(address author) external view returns (uint256[] memory) {
    return userPosts[author];
  }

  function getPostById(uint256 postId) external view returns (Post memory) {
    return posts[postId];
  }

  function getManyPosts(uint256[] calldata postIds) external view returns (Post[] memory) {
    Post[] memory manyPosts = new Post[](postIds.length);
    for (uint256 i = 0; i < postIds.length; i++) {
      manyPosts[i] = posts[postIds[i]];
    }
    return manyPosts;
  }

  function getLatestPostIds(uint256 count) external view returns (uint256[] memory) {
    uint256 totalPosts = nextPostId;
    uint256 validCount = 0;
    uint256[] memory temp = new uint256[](count);

    for (uint256 i = totalPosts; i > 0 && validCount < count; i--) {
      uint256 postId = i - 1;
      if (!posts[postId].isDeleted) {
        temp[validCount] = postId;
        validCount++;
      }
    }

    uint256[] memory result = new uint256[](validCount);
    for (uint256 j = 0; j < validCount; j++) {
      result[j] = temp[j];
    }

    return result;
  }

  function getPostIdsPaginated(uint256 offset, uint256 limit) external view returns (uint256[] memory) {
    uint256 totalPosts = nextPostId;
    uint256[] memory temp = new uint256[](limit);
    uint256 validCount = 0;
    uint256 skipped = 0;

    for (uint256 i = totalPosts; i > 0 && validCount < limit; i--) {
      uint256 postId = i - 1;

      if (posts[postId].isDeleted) {
        continue;
      }

      if (skipped < offset) {
          skipped++;
          continue;
      }

      temp[validCount] = postId;
      validCount++;
    }

    uint256[] memory result = new uint256[](validCount);
    for (uint256 j = 0; j < validCount; j++) {
      result[j] = temp[j];
    }

    return result;
  }

}