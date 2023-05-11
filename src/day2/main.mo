import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";

import Types "Types";
import Text "mo:base/Text";


actor class Homework() {

  type Homework = Types.Homework;

  //homeworks Array
  let homeworkDiary = Buffer.Buffer<Homework>(0);


  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    homeworkDiary.add(homework);
    return homeworkDiary.size() - 1;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    if (id >= homeworkDiary.size()) {
      return #err("Homework task does not exist");
    };
    let homeworkDiary_array = Buffer.toArray(homeworkDiary);
    return #ok(homeworkDiary_array[id]);
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(homeworkId : Nat, homework : Homework) : async Result.Result<(), Text> {
    if (homeworkId >= homeworkDiary.size()) {
      return #err("Invalid homework id");
    };
    let updatedHomework = {
      title = homework.title;
      description = homework.description;
      dueDate = homework.dueDate;
      completed = homework.completed;
    };
    let x = homeworkDiary.put(homeworkId, updatedHomework);
    return #ok();
  };  

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
      if (id >= homeworkDiary.size()) {
        return #err("Homework task does not exist");
      };
      let homeworkDiary_array = Buffer.toArray(homeworkDiary);
      let homework = homeworkDiary_array[id];
      let updatedHomework = { homework with completed = true };
      let x = homeworkDiary.put(id, updatedHomework);

      return #ok(());
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    if (id >= homeworkDiary.size()) {
      return #err("Invalid homework ID");
    };
    let x = homeworkDiary.remove(id);
    return #ok(());
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    return (Buffer.toArray(homeworkDiary));
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    var matchingHomework = Buffer.Buffer<Homework>(0);

    for (homework in homeworkDiary.vals()) {
        if (Text.contains(homework.title, #text searchTerm) or Text.contains(homework.description, #text searchTerm)) { 
                matchingHomework.add(homework);
        };
    };

    return Buffer.toArray(matchingHomework);
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
      var pendingHomework = Buffer.Buffer<Homework>(0);
      for (homework in homeworkDiary.vals()) {
        if (homework.completed != true) {
          pendingHomework.add(homework);
        };
      };
      return (Buffer.toArray(pendingHomework));
  };
};  
