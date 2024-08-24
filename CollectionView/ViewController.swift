//
//  ViewController.swift
//  CollectionView
//
//  Created by Steven Kirke on 24.08.2024.
//

import UIKit

struct TestElement {
	let title: String
	var isVisible: Bool
	let series: [String]
}

class MainViewController: UIViewController {

	// MARK: - Private properties

	lazy var collectionCardView = createCollectionView()

	var model: [TestElement] = [
		TestElement(title: "ONE", isVisible: false, series: ["ONE", "TWO", "THREE"]),
		TestElement(title: "TWO", isVisible: true, series: ["ONE", "TWO"]),
		TestElement(title: "THREE", isVisible: false, series: ["ONE"]),
		TestElement(title: "FOUR", isVisible: true, series: ["ONE", "TWO", "THREE", "FOUR"]),
		TestElement(title: "FIVE", isVisible: false, series: ["ONE", "TWO"]),
		TestElement(title: "SIX", isVisible: true, series: ["ONE", "TWO", "THREE"])
	]

	// MARK: - Initializator
	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Public methods
	// MARK: - Public methods
	override func viewDidLoad() {
		super.viewDidLoad()
		setupConfiguration()
		addUIView()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		setupLayout()
	}

	func reloadCollectionView() {
		collectionCardView.reloadData()
	}
}

// MARK: - Add UIView.
private extension MainViewController {
	func addUIView() {
		view.addSubview(collectionCardView)
	}
}

// MARK: - UI configuration.
private extension MainViewController {
	/// Настройка UI элементов
	func setupConfiguration() {
		collectionCardView.delegate = self
		collectionCardView.dataSource = self
		collectionCardView.register(ExpandableCell.self, forCellWithReuseIdentifier: ExpandableCell.reuseIdentifier)
	}
}

// MARK: - Add constraint.
extension MainViewController {
	@objc func setupLayout() {
		let padding: CGFloat = 20
		NSLayoutConstraint.activate([
			collectionCardView.topAnchor.constraint(equalTo: view.topAnchor, constant: padding / 2),
			collectionCardView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding),
			collectionCardView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -padding),
			collectionCardView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
	}
}

// MARK: - CollectionView Flow Layout.
extension MainViewController: UICollectionViewDelegateFlowLayout {
	/// Настройка размеров ячейки.
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		let padding: CGFloat = 20
		let heightCell: CGFloat = 50
		var totalHeight: CGFloat = heightCell

		let item = model[indexPath.item]
		let countModel = CGFloat(item.series.count)
		if !item.isVisible {
			totalHeight += (totalHeight * countModel)
		}
		return CGSize(width: view.frame.width - padding, height: totalHeight)
	}
}

// MARK: - CollectionView Source and Delegate.
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		model.count
	}

	func collectionView(
		_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		var cell = UICollectionViewCell()
		cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExpandableCell.reuseIdentifier, for: indexPath)
		guard let currentCell = cell as? ExpandableCell else { return cell }
		let model = model[indexPath.item]
		currentCell.reloadData(index: indexPath.item, model: model.series)
		currentCell.delegate = self
		currentCell.changeVisibility(isHidden: model.isVisible)
		return currentCell
	}
}

// MARK: - UI Fabric.
private extension MainViewController {
	func createCollectionView() -> UICollectionView {
		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = 10
		layout.minimumLineSpacing = 10
		layout.scrollDirection = .vertical

		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.showsVerticalScrollIndicator = false
		collectionView.clipsToBounds = true
		collectionView.translatesAutoresizingMaskIntoConstraints = false

		return collectionView
	}
}

extension MainViewController: IExpandableCellDelegate {
	func handlerCell(index: Int) {
		model[index].isVisible.toggle()
		reloadCollectionView()
	}

	func checkItem(index: Int, tag: Int) {

	}
}

protocol IExpandableCellDelegate: AnyObject {
	func handlerCell(index: Int)
	func checkItem(index: Int, tag: Int)
}

class ExpandableCell: UICollectionViewCell {
	// MARK: - Dependencies
	var delegate: IExpandableCellDelegate!

	// MARK: - Public properties
	static let reuseIdentifier = "CellSeries.cell"

	// MARK: - Private properties

	private lazy var stackVertical = createStack()
	private lazy var buttonTitle = createButton()

	// MARK: - Initializator
	convenience init(delegate: IExpandableCellDelegate) {
		self.init(frame: CGRect.zero)
		self.delegate = delegate
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		addUIView()
		setupConfiguration()
		setupLayout()
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)!
	}

	// MARK: - Public methods
	func reloadData(index: Int, model: [String]) {

		buttonTitle.tag = index
		generateContent(models: model)
	}

	func changeVisibility(isHidden: Bool) {
		self.stackVertical.isHidden = isHidden
	}

	private func generateContent(models: [String]) {
		while stackVertical.arrangedSubviews.count < models.count {
			stackVertical.addArrangedSubview(ButtonTestCellSeries(delegate: self))
		}

		let zipArray = zip(stackVertical.arrangedSubviews, models)
		for (index, model) in zipArray.enumerated() {
			if let currentButton = model.0 as? ButtonTestCellSeries {
				currentButton.reloadData(title: model.1, tag: index)
				setupButton(currentButton)
			}
		}

		for (index, currentButton) in stackVertical.arrangedSubviews.enumerated() {
			currentButton.isHidden = !(index < models.count)
		}
	}
}

// MARK: - Add UIView.
private extension ExpandableCell {
	func addUIView() {
		let views: [UIView] = [
			buttonTitle,
			stackVertical
		]
		views.forEach(addSubview)
	}
}

// MARK: - UI configuration.
private extension ExpandableCell {
	func setupConfiguration() {
		self.backgroundColor = UIColor.gray.withAlphaComponent(0.5)

		buttonTitle.addTarget(self, action: #selector(showList), for: .touchUpInside)
	}
}

// MARK: - Add constraint.
private extension ExpandableCell {
	func setupLayout() {
		NSLayoutConstraint.activate([
			buttonTitle.topAnchor.constraint(equalTo: self.topAnchor),
			buttonTitle.leftAnchor.constraint(equalTo: self.leftAnchor),
			buttonTitle.rightAnchor.constraint(equalTo: self.rightAnchor),
			buttonTitle.heightAnchor.constraint(equalToConstant: 50),

			stackVertical.topAnchor.constraint(equalTo: buttonTitle.bottomAnchor),
			stackVertical.leftAnchor.constraint(equalTo: self.leftAnchor),
			stackVertical.rightAnchor.constraint(equalTo: self.rightAnchor),
			stackVertical.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
	}

	func setupButton(_ button: ButtonTestCellSeries) {
		NSLayoutConstraint.activate([
			button.leftAnchor.constraint(equalTo: self.leftAnchor),
			button.rightAnchor.constraint(equalTo: self.rightAnchor)
		])
	}
}

// MARK: - UI Fabric.
private extension ExpandableCell {
	func createStack() -> UIStackView {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.distribution = .fillEqually
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}

	func createButton() -> UIButton {
		let button = UIButton()
		button.setTitle("CLICK", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}
}

// MARK: - UI Action.
private extension ExpandableCell {
	@objc func showList() {
		self.delegate.handlerCell(index: buttonTitle.tag)
	}
}

// MARK: - Delegate.
extension ExpandableCell: IButtonTestViewCellDelegate {
	func checkButton(tag: Int) {
		self.delegate.checkItem(index: self.buttonTitle.tag, tag: tag)
	}
}

protocol IButtonTestViewCellDelegate: AnyObject {
	func checkButton(tag: Int)
}

class ButtonTestCellSeries: UIView {

	// MARK: - Dependencies
	var delegate: IButtonTestViewCellDelegate!

	private lazy var button = createButton()

	// MARK: - Initializator
	init(delegate: IButtonTestViewCellDelegate) {
		super.init(frame: .zero)
		self.addUIView()
		self.setupConfiguration()
		self.setupLayout()
		self.delegate = delegate
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Public methods
	public func reloadData(title: String, tag: Int) {
		self.button.setTitle(title, for: .normal)
		self.button.tag = tag
	}
}

// MARK: - Add UIView.
private extension ButtonTestCellSeries {
	func addUIView() {
		let views: [UIView] = [
			button
		]
		views.forEach(addSubview)
	}
}

// MARK: - UI configuration.
private extension ButtonTestCellSeries {
	func setupConfiguration() {
		button.addTarget(self, action: #selector(buttonTab), for: .touchUpInside)
	}
}

// MARK: - Add constraint.
private extension ButtonTestCellSeries {
	func setupLayout() {
		NSLayoutConstraint.activate([
			button.topAnchor.constraint(equalTo: self.topAnchor),
			button.leftAnchor.constraint(equalTo: self.leftAnchor),
			button.rightAnchor.constraint(equalTo: self.rightAnchor),
			button.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
	}
}

// MARK: - UI Fabric.
private extension ButtonTestCellSeries {
	func createButton() -> UIButton {
		let button = UIButton()
		button.setTitleColor(UIColor.black, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}
}

// MARK: - UI Action.
private extension ButtonTestCellSeries {
	@objc func buttonTab(_ sender: UIButton) {
		delegate.checkButton(tag: button.tag)
	}
}
