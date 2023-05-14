import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Hash "mo:base/Hash";
import Option "mo:base/Option";
import List "mo:base/List";
import Int "mo:base/Int";
import Order "mo:base/Order";


actor class StudentWall() {
  type Message = Type.Message;
  type Content = Type.Content;
  type Survey = Type.Survey;
  type Answer = Type.Answer;
  
  //continuously increasing counter
  var messageIdCounter: Nat = 0;

  //Store messages.
  var wall = HashMap.HashMap<Nat, Message>(0,Nat.equal, Hash.hash);

  type Order = Order.Order;
  func compareMesaage(m1: Message, m2: Message): Order {
    if (m1.vote == m2.vote){
      return #equal
    };
    if (m1.vote > m2.vote){
      return #less
    };
    return #greater
  };

  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
      // Increment message ID
      messageIdCounter += 1;

      // Create new message
      let message: Type.Message = {
        content = c;
        vote = 0;
        creator : Principal = caller;
      };

      // Add message to wall
      wall.put(messageIdCounter, message);
      return messageIdCounter;
  };
  

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
      // Retrieve the message with the given messageId from the wall canister
      let messageOpt : ?Message = wall.get(messageId);
      
      // Check if the retrieved message exists
      switch (messageOpt) {
        // If the message exists, return the message wrapped in #ok
        case (?message) {
          return #ok(message);
        };
        // If the message does not exist, return an error message wrapped in #err
        case null {
          return #err("Message not found");
        };
      };
  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
      // Get the message by its ID
      let messageOpt = wall.get(messageId);
      // Handle the case where the message ID is invalid
      switch (messageOpt) {
          case (null) {
            return #err("Invalid messageId");
          };
            // Handle the case where the message ID is valid
          case (?message) {
              // Ensure that the caller is the creator of the message
              if (message.creator != caller) {
                return #err("Caller is not the creator of the message");
              };
              // Update the message content with the provided content
              let updatedMessage : Message = {message with content = c};
              wall.put(messageId, updatedMessage);
              // Return a success result
              return #ok();
          };
      };
  };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
      // Get the message by its ID
      let messageOpt = wall.get(messageId);
      
      // Check if the retrieved message exists
      switch (messageOpt) {
        // If the message exists, return the message wrapped in #ok
        case (?message) {
          wall.delete(messageId);
          return #ok(());
        };
        // If the message does not exist, return an error message wrapped in #err
        case null {
          return #err("Invalid messageId");
        };
      };
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
      // Get the message by its ID
      let messageOpt = wall.get(messageId);
      
      // Check if the retrieved message exists
      switch (messageOpt) {
        // If the message exists, return the message wrapped in #ok
        case (?message) {
          // Append a vote to the message
          let updatedMessage : Message = {message with vote = message.vote + 1};
          wall.put(messageId, updatedMessage);
          return #ok();
        };
        // If the message does not exist, return an error message wrapped in #err
        case null {
          return #err("Invalid messageId");
        };
      };
  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
         // Get the message by its ID
      let messageOpt = wall.get(messageId);
      
      // Check if the retrieved message exists
      switch (messageOpt) {
        // If the message exists, return the message wrapped in #ok
        case (?message) {
          // Append a vote to the message
          let updatedMessage : Message = {message with vote = message.vote - 1};
          wall.put(messageId, updatedMessage);
          return #ok();
        };
        // If the message does not exist, return an error message wrapped in #err
        case null {
          return #err("Invalid messageId");
        };
      };
  };

  // Get all messages
  public func getAllMessages() : async [Message] {
      var messageList = Buffer.Buffer<Message>(0);
      for (message in wall.vals()) {
        messageList.add(message);
      };
      return (Buffer.toArray(messageList));
  };

  // Get all messages ordered by votes
  public func getAllMessagesRanked() : async [Message] { 
      let array: [Message] = Iter.toArray(wall.vals());
      return Array.sort<Message>(array, compareMesaage);
  };
}