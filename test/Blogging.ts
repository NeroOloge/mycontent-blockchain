import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("Blogging", function () {
  async function deployBloggingFixture() {
    const [owner, otherAccount] = await hre.ethers.getSigners();

    const Blogging = await hre.ethers.getContractFactory("Blogging");
    const blogging = await Blogging.deploy();

    return { blogging, owner, otherAccount }
  }

  describe("Deployment", function () {

  })

  describe("Post Creation", function () {
    it("should return an empty array when there are no posts", async function () {
      const { blogging, owner } = await loadFixture(deployBloggingFixture)
      const authorPosts = await blogging.getPostsByAuthor(owner.address)
      expect(authorPosts.length).to.equal(0)
    })
    it("should create a post and map the author to the post cid", async function () {
      const { blogging, owner } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      const authorPosts = await blogging.getPostsByAuthor(owner.address)
      expect(authorPosts[0].cid).to.equal("cid1")
    })
    it("should return only posts created by a specific author", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      await blogging.connect(otherAccount).addPost("cid2", Date.now())
      const authorPosts = await blogging.getPostsByAuthor(owner.address)
      expect(authorPosts.length).to.equal(1)
      expect(authorPosts[0].cid).to.equal("cid1")
    })
    it("should add author to list of authors once", async function() {
      const { blogging, owner } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      await blogging.addPost("cid2", Date.now())
      const authors = await blogging.getAuthors()
      expect(authors.length).to.equal(1)
      expect(authors[0]).to.equal(owner.address)
    })
  })

  describe("Post Deletion", function () {
    it("should throw error when deletePost is called for a nonexistent post", async function () {
      const { blogging, owner } = await loadFixture(deployBloggingFixture)
      try {
        await blogging.deletePost("cid1", owner.address)
      } catch (e: any) {
        expect(e?.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Post does not exist'")
      }
    })
    it("should throw error when deletePost is called by a user that's not the author", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      try {
        await blogging.addPost("cid1", Date.now())
        await blogging.connect(otherAccount).deletePost("cid1", owner.address)
      } catch (e: any) {
        expect(e?.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Only post owner can do this action'")
      }
    })
    it("should remove post from list of author posts", async function () {
      const { blogging, owner } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      await blogging.addPost("cid2", Date.now())
      await blogging.addPost("cid3", Date.now())

      await blogging.deletePost("cid2", owner.address)
      const authorPosts = await blogging.getPostsByAuthor(owner.address)
      expect(authorPosts.length).to.equal(2)
    })
    it("should remove author from list of authors when all author's posts are deleted", async function () {
      const { blogging, owner } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())

      await blogging.deletePost("cid1", owner.address)
      const authors = await blogging.getAuthors()
      expect(authors.length).to.equal(0)
    })
    it("should remove post and comments under post from all user comments", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      await blogging.addPost("cid2", Date.now())
      await blogging.addPost("cid3", Date.now())

      await blogging.connect(otherAccount).addComment("cid2", "commentCid1", owner.address, Date.now())
      await blogging.addComment("cid2", "commentCid2", owner.address, Date.now())
      await blogging.addComment("cid1", "commentCid3", owner.address, Date.now())
      await blogging.connect(otherAccount).addComment("cid3", "commentCid4", owner.address, Date.now())

      await blogging.deletePost("cid2", owner.address)
      const user1Comments = await blogging.getCommentsByUser(owner.address)
      const user2Comments = await blogging.getCommentsByUser(otherAccount.address)
      expect(user1Comments.length).to.equal(1)
      expect(user2Comments.length).to.equal(1)
    })
    it("should remove post and likes on post from all user likes", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      await blogging.addPost("cid2", Date.now())
      await blogging.addPost("cid3", Date.now())

      await blogging.connect(otherAccount).like("cid2", owner.address)
      await blogging.like("cid2", owner.address)
      await blogging.like("cid1", owner.address)
      await blogging.connect(otherAccount).like("cid3", owner.address)

      await blogging.deletePost("cid2", owner.address)
      const user1Likes = await blogging.getLikesByUser(owner.address)
      const user2Likes = await blogging.getLikesByUser(otherAccount.address)
      expect(user1Likes.length).to.equal(1)
      expect(user2Likes.length).to.equal(1)
    })
  })

  describe("Comment Creation", function () {
    it("should throw an error when commenting on a post that doesn't exist", async function () {
      const { blogging, owner } = await loadFixture(deployBloggingFixture)
      try {
        await blogging.addComment("cid1", "commentCid1", owner.address, Date.now())
      } catch (e: any) {
        expect(e?.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Post does not exist'")
      }
    })
    it("should create a comment that is visible on list of post comments", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      await blogging.connect(otherAccount).addComment("cid1", "commentCid1", owner.address, Date.now())
      const postComments = await blogging.getCommentsByPost("cid1")
      expect(postComments.length).to.equal(1)
      expect(postComments[0].cid).to.equal("commentCid1")
    })
  })

  describe("Comment Deletion", function () {
    it("should throw an error when deleting a comment that doesn't exist", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      try {
        await blogging.addPost("cid1", Date.now())
        await blogging.deleteComment("cid1", "commentCid1", owner.address, otherAccount.address)
      } catch (e: any) {
        expect(e?.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Comment does not exist'")
      }
    })
    it("should delete comment from list of post comments", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      await blogging.connect(otherAccount).addComment("cid1", "commentCid1", owner.address, Date.now())
      await blogging.connect(otherAccount).addComment("cid1", "commentCid2", owner.address, Date.now())
      await blogging.connect(otherAccount).addComment("cid1", "commentCid3", owner.address, Date.now())
      
      await blogging.deleteComment("cid1", "commentCid2", owner.address, otherAccount.address)
      const postComments = await blogging.getCommentsByPost("cid1")
      expect(postComments.length).to.equal(2)
    })
    it("should delete comment from list of user comments", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      await blogging.connect(otherAccount).addComment("cid1", "commentCid1", owner.address, Date.now())
      await blogging.connect(otherAccount).addComment("cid1", "commentCid2", owner.address, Date.now())
      await blogging.connect(otherAccount).addComment("cid1", "commentCid3", owner.address, Date.now())
      
      await blogging.deleteComment("cid1", "commentCid2", owner.address, otherAccount.address)
      const userComments = await blogging.getCommentsByUser(otherAccount.address)
      expect(userComments.length).to.equal(2)
    })
  })

  describe("Liking", function () {
    it("should add user address to list of post likes", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      await blogging.connect(otherAccount).like("cid1", owner.address)
      await blogging.like("cid1", owner.address)

      const postLikes = await blogging.getLikesNumberByPost("cid1")
      expect(postLikes).to.equal(2)
    })
    it("should add post cid to list of user liked posts", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      await blogging.addPost("cid2", Date.now())
      await blogging.connect(otherAccount).like("cid1", owner.address)
      await blogging.connect(otherAccount).like("cid2", owner.address)
      await blogging.like("cid1", owner.address)

      const userLikes = await blogging.getLikesByUser(otherAccount.address)
      expect(userLikes.length).to.equal(2)
    })
    it("should throw an error when double-liking the same post", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      try {
        await blogging.addPost("cid1", Date.now())
        await blogging.connect(otherAccount).like("cid1", owner.address)
        await blogging.connect(otherAccount).like("cid1", owner.address)
      } catch (e: any) {
        expect(e?.message).to.equal("VM Exception while processing transaction: reverted with reason string 'User already liked post'")
      }

    })
  })

  describe("Unliking", function () {
    it("should remove user address to list of post likes", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      await blogging.connect(otherAccount).like("cid1", owner.address)
      await blogging.like("cid1", owner.address)

      await blogging.unlike("cid1", owner.address)

      const postLikes = await blogging.getLikesNumberByPost("cid1")
      expect(postLikes).to.equal(1)
    })
    it("should remove post cid to list of user liked posts", async function () {
      const { blogging, owner, otherAccount } = await loadFixture(deployBloggingFixture)
      await blogging.addPost("cid1", Date.now())
      await blogging.addPost("cid2", Date.now())
      await blogging.connect(otherAccount).like("cid1", owner.address)
      await blogging.connect(otherAccount).like("cid2", owner.address)
      await blogging.like("cid1", owner.address)

      await blogging.connect(otherAccount).unlike("cid1", owner.address)

      const userLikes = await blogging.getLikesByUser(otherAccount.address)
      expect(userLikes.length).to.equal(1)
    })
  })
})