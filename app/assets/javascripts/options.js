/* 汎用function */
// 配列内にいるかTF
function inArray(element, array){
  for(var i=0;i<array.length;i++){
    if(array[i] == element) return true;
  }
  return false;
}

/* radioボタン1つ目 No category (Reset Categorize) */
function ResetCategorize(){
  // CustomizeのTextboxとButtonを非表示に
  DisappearCustomCategorizeForm();

  // ラベルカテゴリ部分のリセット
  // 要素取得
  var original_label_elems = document.getElementsByName("labels_in_category_customize");
  // 元々のラベルをすべて表示
  for(var i=0;i<original_label_elems.length;i++){
    original_label_elems[i].parentNode.style.display = "block";
  }
  // 新ラベルリストを空に
  document.getElementById("new_labels_output").innerHTML = "";

  // ラベル優先順位部分のリセット
  // 要素取得
  var original_label_elems = document.getElementsByName("labels_in_category_customize");
  var labels_name_array = new Array;
  for(var i=0;i<original_label_elems.length;i++){
    labels_name_array.push(original_label_elems[i].nextSibling.innerHTML);
  }
  //全選択リストのoptionをセット
  var label_priority_selects = document.getElementsByName("label_pri_selects[]");
  for(var k=0;k<label_priority_selects.length;k++){
    SetSelectList(label_priority_selects[k], labels_name_array);
  }

  // Issue項目部分のリセット
  // 要素取得
  var issue_items = document.getElementById("issue_items");
  var labels_in_items_elems = document.getElementsByName("labels_in_items[]");
  var labels_in_items_new_elems = document.getElementsByName("labels_in_items_new[]");
  // 元々のラベルを表示
  for(var i=0;i<labels_in_items_elems.length;i++){
    labels_in_items_elems[i].parentNode.style.display = "block";
  }
  // 新ラベル部分を削除
  for(var i=labels_in_items_new_elems.length-1;i>=0;i--){
    issue_items.removeChild(labels_in_items_new_elems[i].parentNode);
  }
  return;
}

/* radioボタン2つ目 Colon means category */
// ":"でカテゴリ分け
function CategorizeByColon(){
  // CustomizeのTextboxとButtonを非表示に
  DisappearCustomCategorizeForm();

  var partition = ":"
  var original_label_elems = document.getElementsByName("labels_in_category_customize");

  // カテゴリ化をする回数の最大値。while文を回避するため
  var max_loop = original_label_elems.length / 2;
  for(var k=0;k<max_loop;k++){
    // 表示されているラベルでColonを含むものがいるならば新ラベル名を取り出す
    // 該当なしの場合ループ終了
    var roop_end_flag = true;
    var new_label_name;
    for(var i=0;i<original_label_elems.length;i++){
      var original_label_name = original_label_elems[i].nextSibling.innerHTML;
      if(original_label_elems[i].parentNode.style.display == "none") continue;
      if(original_label_name.indexOf(partition) == -1) continue;
      var new_label_name = original_label_name.substr(0, original_label_name.indexOf(partition));
      roop_end_flag = false;
      break;
    }
    if(roop_end_flag) break;

    // 新ラベルに吸収されるラベルのcheckboxのみにcheckをつける
    for(var i=0;i<original_label_elems.length;i++){
      var original_label_name = original_label_elems[i].nextSibling.innerHTML;
      if(original_label_name.indexOf(new_label_name + partition) != -1){
        original_label_elems[i].checked = true;
      }else{
        original_label_elems[i].checked = false;
      }
    }
    // InputTextboxに新ラベル名をセット
    document.getElementById("new_label_input").value = new_label_name;
    // カテゴリ化を実行
    Categorize();
  }
  return;
}

/* radioボタン3つ目 Customize */
// CustomizeのTextboxとButtonを表示
function AppearCustomCategorizeForm(){
  var new_label_input_forms = document.getElementsByName("new_label_input_form");
  for(var i=0;i<new_label_input_forms.length;i++){
    new_label_input_forms[i].style.display = "block";
  }
  return;
}
// CustomizeのTextboxとButtonを非表示。Radioボタン1つ目または2つ目を押したとき用
function DisappearCustomCategorizeForm(){
  var new_label_input_forms = document.getElementsByName("new_label_input_form");
  for(var i=0;i<new_label_input_forms.length;i++){
    new_label_input_forms[i].style.display = "none";
  }
  return;
}

/* カテゴリ化本体 */
// 生成ラベル構造体
function generatedLabel(name, components){
  this.name = name;
  this.components = components
}

// ラベルカテゴリのカスタマイズ(main)
function Categorize(){
  var original_label_elems = document.getElementsByName("labels_in_category_customize");
  var new_label_name = document.getElementById("new_label_input").value;
  var new_label_components = new Array;
  for(var i=0;i<original_label_elems.length;i++){
    if(original_label_elems[i].checked){
      new_label_components.push(original_label_elems[i].nextSibling.innerHTML);
    }
  }
  var new_label = new generatedLabel(new_label_name, new_label_components);
  var generated_labels_text = document.getElementById("new_labels_output").innerHTML;
  var generated_labels = generatedLabels_Text_to_Array(generated_labels_text);

  // 新しいラベルが正当なら生成ラベルリストに追加
  if(!isValidNewLabel(new_label, generated_labels, original_label_elems)) return;
  generated_labels.push(new_label);

  // ラベルカテゴリ部分
  // InputBoxを空にリセット
  ClearInputTextBox();
  // 選択肢内で新ラベルに吸収された旧ラベルを非表示に
  HiddenLabelsSelected(original_label_elems, new_label);
  // 生成ラベルリストの表示の更新
  UpdateNewLabelsList(generated_labels);

  // ラベル優先順位部分
  // ラベル優先順位を生成ラベルに対応するように更新
  UpdateLabelPriority(original_label_elems, generated_labels);

  // Issue項目部分
  // Issue項目を生成ラベルに対応するように更新
  UpdateIssueItems(generated_labels);
  return;
}

// 新ラベルが正当か判断する
function isValidNewLabel(new_label, generated_labels, original_label_elems){
  // 1つもラベルのチェックボックスがチェックされていない
  if(new_label.components.length == 0){
    alert("Select label");
    return false;
  }
  // 新ラベル名が空白
  if(new_label.name == ""){
    alert("The label's name is empty");
    return false;
  }
  // すでに生成されたラベルと新ラベルの名前が同じ
  var generated_labels_name_array = new Array;
  for(var i=0;i<generated_labels.length;i++){
    generated_labels_name_array.push(generated_labels[i].name);
  }
  if(inArray(new_label.name, generated_labels_name_array)){
    alert("The label's name is in New labels");
    return false;
  }
  // 元々あるラベルと新ラベルの名前と同じ
  var original_labels_name_array = new Array;
  for(var i=0;i<original_label_elems.length;i++){
    original_labels_name_array.push(original_label_elems[i].nextSibling.innerHTML);
  }
  if(inArray(new_label.name, original_labels_name_array)){
    alert("The label's name is in Original labels");
    return false;
  }
  return true;
}

// 新しいラベルの名前入力テキストボックスを空にする
function ClearInputTextBox(){
  document.getElementById("new_label_input").value = "";
  return;
}

// 生成ラベルリストの配列から生成ラベルリストのテキストを生成
function generatedLabels_Array_to_Text(generated_labels_array){
  var generated_labels_text = "";
  for(var i=0;i<generated_labels_array.length;i++){
    var label = generated_labels_array[i];
    generated_labels_text += "<li>";
    generated_labels_text += "[" + label.name + "]";
    for(var j=0;j<label.components.length;j++){
      generated_labels_text += " " + label.components[j];
    }
    generated_labels_text += "</li>";
  }
  return generated_labels_text;
}

// 生成ラベルリストのテキストから生成ラベルリストの配列を生成
function generatedLabels_Text_to_Array(generated_labels_text){
  if(generated_labels_text.length == 0) return new Array;

  generated_labels_text = generated_labels_text.split("<li>").join("");
  var strs = generated_labels_text.split("</li>");
  strs.pop();

  var generated_labels_array = new Array;
  for(var i=0;i<strs.length;i++){
    var label_data = strs[i].split(" ");
    var label_name = label_data[0].substring(label_data[0].indexOf("[") + 1, label_data[0].indexOf("]"));
    var label_components = new Array;
    for(var j=1;j<label_data.length;j++){
      label_components.push(label_data[j]);
    }
    generated_labels_array.push(new generatedLabel(label_name, label_components));
  }
  return generated_labels_array;
}

// 生成ラベルリストの表示を更新
function UpdateNewLabelsList(generated_labels){
  generated_labels_text = generatedLabels_Array_to_Text(generated_labels);
  document.getElementById("new_labels_output").innerHTML = generated_labels_text;
  return;
}

// 新ラベルに吸収された旧ラベルを非表示に
function HiddenLabelsSelected(original_label_elems, new_label){
  var labels_selected = new Array;
  for(var i=0;i<new_label.components.length;i++){
    labels_selected.push(new_label.components[i]);
  }

  for(var i=0;i<labels_selected.length;i++){
    for(var j=0;j<original_label_elems.length;j++){
      if(labels_selected[i] == original_label_elems[j].nextSibling.innerHTML){
        original_label_elems[j].checked = false;
        original_label_elems[j].parentNode.style.display = "none";
      }
    }
  }
  return;
}

// ラベル優先順位を生成ラベルに対応するように更新
function UpdateLabelPriority(original_label_elems, generated_labels){
  var labels_name_array = new Array;
  for(var i=0;i<original_label_elems.length;i++){
    if(original_label_elems[i].parentNode.style.display == "none") continue;
    labels_name_array.push(original_label_elems[i].nextSibling.innerHTML);
  }
  for(var i=0;i<generated_labels.length;i++){
    labels_name_array.push(generated_labels[i].name);
  }
  //全選択リストのoptionをセット
  var label_priority_selects = document.getElementsByName("label_pri_selects[]");
  for(var k=0;k<label_priority_selects.length;k++){
    SetSelectList(label_priority_selects[k], labels_name_array);
  }
  return;
}
// 選択リストのoptionをセットする
function SetSelectList(select_list, labels_name_array){
  // 一旦optionを全て削除
  var childs = select_list.childNodes;
  for(var i=childs.length-1;i>=0;i--){
    select_list.removeChild(childs[i]);
  }
  // optionを生成
  var elem_option = document.createElement("option");
  elem_option.innerHTML = "-";
  select_list.appendChild(elem_option);
  for(var i=0;i<labels_name_array.length;i++){
    var elem_option = document.createElement("option");
    elem_option.innerHTML = labels_name_array[i];
    select_list.appendChild(elem_option);
  }
  return;
}

// Issue項目を生成ラベルに対応するように更新
function UpdateIssueItems(generated_labels){
  var issue_items = document.getElementById("issue_items");
  var labels_in_items_elems = document.getElementsByName("labels_in_items[]");
  var labels_in_items_new_elems = document.getElementsByName("labels_in_items_new[]");

  // 生成ラベルに吸収された旧ラベルを非表示に
  for(var i=0;i<labels_in_items_elems.length;i++){
    var label_in_item_name = labels_in_items_elems[i].nextSibling.innerHTML;
    for(var j=0;j<generated_labels.length;j++){
      for(var k=0;k<generated_labels[j].components.length;k++){
        if(label_in_item_name == generated_labels[j].components[k]){
          labels_in_items_elems[i].checked = false;
          labels_in_items_elems[i].parentNode.style.display = "none";
        }
      }
    }
  }

  // 生成ラベル部分の生成
  for(var i=0;i<generated_labels.length;i++){
    // 生成ラベルが前回までの更新により既に存在する場合は重複生成を防止
    var generate_flag = true;
    for(var j=0;j<labels_in_items_new_elems.length;j++){
      var label_in_item_new_name = labels_in_items_new_elems[j].nextSibling.innerHTML;
      if(label_in_item_new_name == generated_labels[i].name){
        generate_flag = false;
      }
    }
    if(!generate_flag) continue;

    var elem_label = document.createElement("label");
    elem_label.setAttribute("class", "checkbox");
    elem_label.setAttribute("style", "display: block;");
    issue_items.appendChild(elem_label);

    var elem_checkbox = document.createElement("input");
    elem_checkbox.setAttribute("type", "checkbox");
    elem_checkbox.setAttribute("name", "labels_in_items_new[]");
    elem_checkbox.setAttribute("value", generated_labels[i].name);
    elem_label.appendChild(elem_checkbox);

    var elem_span = document.createElement("span");
    elem_span.innerHTML = generated_labels[i].name;
    elem_label.appendChild(elem_span);
  }
  return;
}

/* 送信ボタン BeforeSubmission */
function BeforeSubmission(){
  UpdateNewLabelsListTransmittedData();
  return;
}

// 生成ラベルリストのテキストから生成ラベルリストの送信データを作成
function generated_Labels_Text_to_TransmitData(generated_labels_text){
  generated_labels_text = generated_labels_text.split("<li>").join("");
  var strs = generated_labels_text.split("</li>");
  strs.pop();
  var data = strs.join("\n");
  return data;
}
// 生成ラベルリストの送信データを更新
function UpdateNewLabelsListTransmittedData(){
  var generated_labels_text = document.getElementById("new_labels_output").innerHTML;
  var new_labels_data = document.getElementById("new_labels_output_data");
  var data = generated_Labels_Text_to_TransmitData(generated_labels_text);
  new_labels_data.value = data;
  return;
}
