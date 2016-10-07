Spree::Product.class_eval do
  has_and_belongs_to_many  :parts, :class_name => "Spree::Variant",
        :join_table => "spree_assemblies_parts",
        :foreign_key => "assembly_id", :association_foreign_key => "part_id"

  has_many :assemblies_parts, :class_name => "Spree::AssembliesPart",
    :foreign_key => "assembly_id"

  scope :individual_saled, -> { where(individual_sale: true) }

  scope :search_can_be_part, ->(query){ not_deleted.available.joins(:master).joins(:translations)
    .where(["spree_product_translations.name like ? or spree_variants.sku like ?", "%#{query}%", "%#{query}%"])
    .where(can_be_part: true)
    .limit(30)
  }

  validate :assembly_cannot_be_part, :if => :assembly?

  def assembly?
    parts.present?
  end

  def count_of(variant)
    ap = assemblies_part(variant)
    # This checks persisted because the default count is 1
    ap.persisted? ? ap.count : 0
  end

  def assembly_cannot_be_part
    errors.add(:can_be_part, Spree.t(:assembly_cannot_be_part)) if can_be_part
  end

  private
  def assemblies_part(variant)
    Spree::AssembliesPart.get(self.id, variant.id)
  end
end
